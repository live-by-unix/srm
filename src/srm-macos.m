// srm-macos - macOS native Trash helper
// Uses NSFileManager to move files to Finder Trash
// Copyright (c) 2026 live-by-unix
// BSD 3-Clause License

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>

static int trash_file(const char *path) {
    @autoreleasepool {
        NSString *pathString = [NSString stringWithUTF8String:path];
        NSURL *fileURL = [NSURL fileURLWithPath:pathString];

        if (!fileURL) {
            fprintf(stderr, "srm-macos: invalid path: %s\n", path);
            return 1;
        }

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSURL *resultingURL = nil;

        BOOL success = [fileManager trashItemAtURL:fileURL
                                  resultingItemURL:&resultingURL
                                             error:&error];

        if (!success) {
            if (error) {
                NSString *errorMessage = [error localizedDescription];
                fprintf(stderr, "srm-macos: failed to move to Trash: %s\n",
                        [errorMessage UTF8String]);
            } else {
                fprintf(stderr, "srm-macos: failed to move to Trash: %s\n", path);
            }
            return 1;
        }

        return 0;
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: srm-macos <file>...\n");
        return 1;
    }

    int failures = 0;
    for (int i = 1; i < argc; i++) {
        if (trash_file(argv[i]) != 0) {
            failures++;
        }
    }

    return failures > 0 ? 1 : 0;
}
