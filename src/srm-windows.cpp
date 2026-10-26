// srm-windows - Windows native Recycle Bin helper
// Uses IFileOperation API to move files to Recycle Bin
// Copyright (c) 2026 live-by-unix
// BSD 3-Clause License

#include <windows.h>
#include <shobjidl.h>
#include <shlwapi.h>
#include <stdio.h>
#include <tchar.h>

#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "shlwapi.lib")

// Progress sink implementation for IFileOperation
class FileOperationProgressSink : public IFileOperationProgressSink {
public:
    FileOperationProgressSink() : m_refCount(1) {}

    // IUnknown
    STDMETHODIMP QueryInterface(REFIID riid, void **ppv) {
        if (riid == IID_IUnknown || riid == IID_IFileOperationProgressSink) {
            *ppv = static_cast<IFileOperationProgressSink*>(this);
            AddRef();
            return S_OK;
        }
        *ppv = NULL;
        return E_NOINTERFACE;
    }

    STDMETHODIMP_(ULONG) AddRef() {
        return InterlockedIncrement(&m_refCount);
    }

    STDMETHODIMP_(ULONG) Release() {
        LONG ref = InterlockedDecrement(&m_refCount);
        if (ref == 0) {
            delete this;
        }
        return ref;
    }

    // IFileOperationProgressSink methods (minimal implementation)
    STDMETHODIMP StartOperations() { return S_OK; }
    STDMETHODIMP FinishOperations(HRESULT) { return S_OK; }
    STDMETHODIMP PreRenameItem(DWORD, IShellItem *, LPCWSTR) { return S_OK; }
    STDMETHODIMP PostRenameItem(DWORD, IShellItem *, LPCWSTR, HRESULT, IShellItem *) { return S_OK; }
    STDMETHODIMP PreCopyItem(DWORD, IShellItem *, IShellItem *, LPCWSTR) { return S_OK; }
    STDMETHODIMP PostCopyItem(DWORD, IShellItem *, IShellItem *, LPCWSTR, HRESULT, IShellItem *) { return S_OK; }
    STDMETHODIMP PreMoveItem(DWORD, IShellItem *, IShellItem *, LPCWSTR) { return S_OK; }
    STDMETHODIMP PostMoveItem(DWORD, IShellItem *, IShellItem *, LPCWSTR, HRESULT, IShellItem *) { return S_OK; }
    STDMETHODIMP PreDeleteItem(DWORD, IShellItem *) { return S_OK; }

    STDMETHODIMP PostDeleteItem(DWORD, IShellItem *, HRESULT, IShellItem *) {
        // This is called after the delete operation
        // We can check the HRESULT here
        return S_OK;
    }

    STDMETHODIMP UpdateProgress(UINT, UINT) { return S_OK; }
    STDMETHODIMP ResetTimer() { return S_OK; }
    STDMETHODIMP PauseTimer() { return S_OK; }
    STDMETHODIMP ResumeTimer() { return S_OK; }

private:
    LONG m_refCount;
};

// Create IShellItem from path
static HRESULT CreateShellItemFromPath(LPCWSTR path, IShellItem **ppsi) {
    *ppsi = NULL;

    // Check if path is absolute
    if (PathIsRelativeW(path)) {
        wchar_t fullPath[MAX_PATH];
        if (GetCurrentDirectoryW(MAX_PATH, fullPath) == 0) {
            return HRESULT_FROM_WIN32(GetLastError());
        }
        if (!PathAppendW(fullPath, path)) {
            return E_FAIL;
        }
        return SHCreateItemFromParsingName(fullPath, NULL, IID_PPV_ARGS(ppsi));
    }

    return SHCreateItemFromParsingName(path, NULL, IID_PPV_ARGS(ppsi));
}

// Move file to Recycle Bin
static BOOL RecycleFile(LPCWSTR path) {
    HRESULT hr;
    IFileOperation *pfo = NULL;
    IShellItem *psi = NULL;
    FileOperationProgressSink *pSink = NULL;

    // Initialize COM
    hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) {
        fwprintf(stderr, L"srm-windows: COM initialization failed: 0x%08lx\n", hr);
        return FALSE;
    }

    // Create IFileOperation object
    hr = CoCreateInstance(CLSID_FileOperation, NULL, CLSCTX_ALL,
                          IID_PPV_ARGS(&pfo));
    if (FAILED(hr)) {
        fwprintf(stderr, L"srm-windows: failed to create IFileOperation: 0x%08lx\n", hr);
        CoUninitialize();
        return FALSE;
    }

    // Set operation flags (no UI)
    hr = pfo->SetOperationFlags(FOF_NO_UI | FOF_NOCONFIRMATION | FOFX_RECYCLEONDELETE);
    if (FAILED(hr)) {
        fwprintf(stderr, L"srm-windows: failed to set operation flags: 0x%08lx\n", hr);
        pfo->Release();
        CoUninitialize();
        return FALSE;
    }

    // Create shell item from path
    hr = CreateShellItemFromPath(path, &psi);
    if (FAILED(hr)) {
        fwprintf(stderr, L"srm-windows: failed to create shell item for '%s': 0x%08lx\n", path, hr);
        pfo->Release();
        CoUninitialize();
        return FALSE;
    }

    // Create progress sink
    pSink = new FileOperationProgressSink();

    // Declare delete operation
    hr = pfo->DeleteItem(psi, pSink);
    if (FAILED(hr)) {
        fwprintf(stderr, L"srm-windows: failed to declare delete: 0x%08lx\n", hr);
        pSink->Release();
        psi->Release();
        pfo->Release();
        CoUninitialize();
        return FALSE;
    }

    // Perform operation
    hr = pfo->PerformOperations();
    if (FAILED(hr)) {
        fwprintf(stderr, L"srm-windows: failed to perform operation: 0x%08lx\n", hr);
        pSink->Release();
        psi->Release();
        pfo->Release();
        CoUninitialize();
        return FALSE;
    }

    // Check if any operations were aborted
    BOOL aborted = FALSE;
    hr = pfo->GetAnyOperationsAborted(&aborted);
    if (SUCCEEDED(hr) && aborted) {
        fwprintf(stderr, L"srm-windows: operation was aborted\n");
        pSink->Release();
        psi->Release();
        pfo->Release();
        CoUninitialize();
        return FALSE;
    }

    // Cleanup
    pSink->Release();
    psi->Release();
    pfo->Release();
    CoUninitialize();

    return TRUE;
}

// Convert UTF-8 to UTF-16
static wchar_t* UTF8ToUTF16(const char* utf8) {
    int len = MultiByteToWideChar(CP_UTF8, 0, utf8, -1, NULL, 0);
    if (len == 0) {
        return NULL;
    }

    wchar_t* utf16 = (wchar_t*)malloc(len * sizeof(wchar_t));
    if (utf16 == NULL) {
        return NULL;
    }

    if (MultiByteToWideChar(CP_UTF8, 0, utf8, -1, utf16, len) == 0) {
        free(utf16);
        return NULL;
    }

    return utf16;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: srm-windows <file>...\n");
        return 1;
    }

    int failures = 0;

    for (int i = 1; i < argc; i++) {
        wchar_t* path = UTF8ToUTF16(argv[i]);
        if (path == NULL) {
            fprintf(stderr, "srm-windows: failed to convert path: %s\n", argv[i]);
            failures++;
            continue;
        }

        if (!RecycleFile(path)) {
            failures++;
        }

        free(path);
    }

    return failures > 0 ? 1 : 0;
}
