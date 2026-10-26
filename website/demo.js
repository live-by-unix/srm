// Interactive Terminal Simulator for srm
// Runs entirely in browser, does not access real filesystem

class SRMDemo {
    constructor() {
        this.filesystem = this.createInitialFilesystem();
        this.trash = [];
        this.currentDir = '/';
        this.history = [];
        this.historyIndex = -1;

        this.init();
    }

    createInitialFilesystem() {
        return {
            '/': {
                type: 'directory',
                children: {
                    'documents': {
                        type: 'directory',
                        children: {
                            'report.txt': { type: 'file', content: 'Report content' },
                            'notes.txt': { type: 'file', content: 'Meeting notes' }
                        }
                    },
                    'downloads': {
                        type: 'directory',
                        children: {
                            'installer.dmg': { type: 'file', content: 'Installer binary' },
                            'backup.zip': { type: 'file', content: 'Backup archive' }
                        }
                    },
                    'project': {
                        type: 'directory',
                        children: {
                            'main.py': { type: 'file', content: 'Main source code' },
                            'config.json': { type: 'file', content: 'Configuration' },
                            'readme.md': { type: 'file', content: 'Documentation' }
                        }
                    },
                    'temp': {
                        type: 'directory',
                        children: {
                            'cache.tmp': { type: 'file', content: 'Cache data' },
                            'temp.log': { type: 'file', content: 'Log file' }
                        }
                    },
                    '--help.txt': { type: 'file', content: 'Help documentation' },
                    '--version.txt': { type: 'file', content: 'Version information' }
                }
            }
        };
    }

    init() {
        this.terminalInput = document.getElementById('terminal-input');
        this.terminalOutput = document.getElementById('terminal-output');
        this.filetreeEl = document.getElementById('filetree');
        this.trashContentsEl = document.getElementById('trash-contents');

        this.terminalInput.addEventListener('keydown', (e) => this.handleInput(e));
        document.getElementById('reset-demo').addEventListener('click', () => this.reset());
        document.getElementById('empty-trash').addEventListener('click', () => this.emptyTrash());

        this.renderFiletree();
        this.renderTrash();
        this.terminalInput.focus();
    }

    handleInput(e) {
        if (e.key === 'Enter') {
            const command = this.terminalInput.value.trim();
            if (command) {
                this.history.push(command);
                this.historyIndex = this.history.length;
                this.executeCommand(command);
            }
            this.terminalInput.value = '';
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (this.historyIndex > 0) {
                this.historyIndex--;
                this.terminalInput.value = this.history[this.historyIndex];
            }
        } else if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (this.historyIndex < this.history.length - 1) {
                this.historyIndex++;
                this.terminalInput.value = this.history[this.historyIndex];
            } else {
                this.historyIndex = this.history.length;
                this.terminalInput.value = '';
            }
        }
    }

    executeCommand(input) {
        this.addOutputLine(`${this.getPrompt()} ${input}`);

        const parts = input.split(' ');
        const command = parts[0];
        const args = parts.slice(1);

        switch (command) {
            case 'srm':
                this.handleSrm(args);
                break;
            case 'srmi':
                this.handleSrmi(args);
                break;
            case 'ls':
                this.handleLs(args);
                break;
            case 'restore':
                this.handleRestore(args);
                break;
            case 'clear':
                this.clearTerminal();
                break;
            case 'help':
                this.showHelp();
                break;
            default:
                this.addOutputLine(`srm: command not found: ${command}`, 'error');
        }

        this.scrollToBottom();
    }

    handleSrm(args) {
        if (args.length === 0) {
            this.addOutputLine('srm: missing operand', 'error');
            this.addOutputLine("Try 'srmi --help' for more information.", 'error');
            return;
        }

        let force = false;
        let recursive = false;
        let verbose = false;
        let files = [];

        // Parse options
        for (const arg of args) {
            if (arg === '-f' || arg === '--force') {
                force = true;
            } else if (arg === '-r' || arg === '-R' || arg === '--recursive') {
                recursive = true;
            } else if (arg === '-v' || arg === '--verbose') {
                verbose = true;
            } else if (arg === '--') {
                // End of options
                continue;
            } else if (arg.startsWith('-')) {
                // Handle combined options
                const opts = arg.slice(1);
                for (const opt of opts) {
                    if (opt === 'f') force = true;
                    else if (opt === 'r' || opt === 'R') recursive = true;
                    else if (opt === 'v') verbose = true;
                }
            } else {
                files.push(arg);
            }
        }

        for (const file of files) {
            const item = this.resolvePath(file);
            if (!item) {
                if (!force) {
                    this.addOutputLine(`srm: cannot remove '${file}': No such file or directory`, 'error');
                }
                continue;
            }

            if (item.type === 'directory' && !recursive) {
                this.addOutputLine(`srm: cannot remove '${file}': is a directory`, 'error');
                continue;
            }

            // Move to trash
            this.moveToTrash(file, item, verbose);
        }

        this.renderFiletree();
        this.renderTrash();
    }

    handleSrmi(args) {
        if (args.length === 0 || args[0] === '--help') {
            this.addOutputLine('srm (Safe RM) - Information');
            this.addOutputLine('');
            this.addOutputLine('NAME');
            this.addOutputLine('    srmi - Display information about srm (Safe RM)');
            this.addOutputLine('');
            this.addOutputLine('OPTIONS');
            this.addOutputLine('    --help      Display this help message');
            this.addOutputLine('    --version   Display version information');
            this.addOutputLine('    --usage     Display brief usage summary');
            this.addOutputLine('    --license   Display license information');
        } else if (args[0] === '--version') {
            this.addOutputLine('srm (Safe RM) version 1.0.0');
            this.addOutputLine('Copyright (c) 2026 live-by-unix');
            this.addOutputLine('BSD 3-Clause License');
            this.addOutputLine('');
            this.addOutputLine('Platform: Demo Simulation');
        } else if (args[0] === '--usage') {
            this.addOutputLine('Usage: srm [OPTION]... FILE...');
            this.addOutputLine('Move files to the native Trash instead of permanently deleting them.');
            this.addOutputLine('');
            this.addOutputLine('Common options:');
            this.addOutputLine('  -f, --force         ignore nonexistent files and arguments');
            this.addOutputLine('  -r, -R, --recursive  remove directories and their contents recursively');
            this.addOutputLine('  -v, --verbose       explain what is being done');
        } else if (args[0] === '--license') {
            this.addOutputLine('BSD 3-Clause License');
            this.addOutputLine('');
            this.addOutputLine('Copyright (c) 2026 live-by-unix');
            this.addOutputLine('');
            this.addOutputLine('Redistribution and use in source and binary forms, with or without');
            this.addOutputLine('modification, are permitted provided that the following conditions are met:');
        } else {
            this.addOutputLine(`srmi: invalid option '${args[0]}'`, 'error');
            this.addOutputLine("Try 'srmi --help' for more information.", 'error');
        }
    }

    handleLs(args) {
        const dir = this.filesystem['/'];
        this.listDirectory(dir, '');
    }

    listDirectory(dir, path) {
        for (const [name, item] of Object.entries(dir.children)) {
            const fullPath = path ? `${path}/${name}` : name;
            if (item.type === 'directory') {
                this.addOutputLine(`${name}/`);
                this.listDirectory(item, fullPath);
            } else {
                this.addOutputLine(name);
            }
        }
    }

    handleRestore(args) {
        if (args.length === 0) {
            this.addOutputLine('restore: missing operand', 'error');
            return;
        }

        const name = args[0];
        const trashIndex = this.trash.findIndex(t => t.name === name);

        if (trashIndex === -1) {
            this.addOutputLine(`restore: '${name}' not found in Trash`, 'error');
            return;
        }

        const item = this.trash[trashIndex];
        this.filesystem['/'].children[item.name] = item.item;
        this.trash.splice(trashIndex, 1);

        this.addOutputLine(`restore: restored '${name}' from Trash`);
        this.renderFiletree();
        this.renderTrash();
    }

    showHelp() {
        this.addOutputLine('Available commands:');
        this.addOutputLine('  srm <file>         - Move file to Trash');
        this.addOutputLine('  srm -r <dir>       - Move directory to Trash recursively');
        this.addOutputLine('  srm -v <file>      - Verbose output');
        this.addOutputLine('  srm -f <file>      - Force mode (ignore missing files)');
        this.addOutputLine('  ls                 - List files');
        this.addOutputLine('  srmi --help        - Show help');
        this.addOutputLine('  restore <file>     - Restore from Trash');
        this.addOutputLine('  clear              - Clear terminal');
    }

    resolvePath(path) {
        // Simplified path resolution for demo
        if (path === '/' || path === '') {
            return this.filesystem['/'];
        }

        const parts = path.split('/').filter(p => p);
        let current = this.filesystem['/'];

        for (const part of parts) {
            if (current.children && current.children[part]) {
                current = current.children[part];
            } else {
                return null;
            }
        }

        return current;
    }

    moveToTrash(path, item, verbose) {
        const name = path.split('/').pop();
        this.trash.push({ name, item, originalPath: path });

        if (verbose) {
            this.addOutputLine(`srm: moved '${path}' to Trash`);
        }
    }

    emptyTrash() {
        this.trash = [];
        this.renderTrash();
        this.addOutputLine('Trash emptied');
    }

    addOutputLine(text, type = '') {
        const line = document.createElement('div');
        line.className = 'terminal-line';

        if (type === 'error') {
            line.innerHTML = `<span class="output-text" style="color: var(--error)">${text}</span>`;
        } else {
            line.innerHTML = `<span class="output-text">${text}</span>`;
        }

        // Remove cursor line
        const cursorLine = this.terminalOutput.querySelector('.cursor');
        if (cursorLine) {
            cursorLine.parentElement.remove();
        }

        this.terminalOutput.appendChild(line);

        // Add new cursor line
        const newCursorLine = document.createElement('div');
        newCursorLine.className = 'terminal-line';
        newCursorLine.innerHTML = `<span class="prompt">${this.getPrompt()}</span><span class="cursor"> </span>`;
        this.terminalOutput.appendChild(newCursorLine);
    }

    getPrompt() {
        return 'user@demo:~$';
    }

    scrollToBottom() {
        this.terminalOutput.scrollTop = this.terminalOutput.scrollHeight;
    }

    clearTerminal() {
        this.terminalOutput.innerHTML = '';
        const line = document.createElement('div');
        line.className = 'terminal-line';
        line.innerHTML = `<span class="prompt">${this.getPrompt()}</span><span class="cursor"> </span>`;
        this.terminalOutput.appendChild(line);
    }

    renderFiletree() {
        this.filetreeEl.innerHTML = '';
        this.renderDirectory(this.filesystem['/'], '');
    }

    renderDirectory(dir, path) {
        for (const [name, item] of Object.entries(dir.children)) {
            const div = document.createElement('div');
            div.className = `file-item ${item.type}`;
            div.textContent = name;
            this.filetreeEl.appendChild(div);

            if (item.type === 'directory') {
                this.renderDirectory(item, path + '/' + name);
            }
        }
    }

    renderTrash() {
        if (this.trash.length === 0) {
            this.trashContentsEl.innerHTML = '<p class="empty-message">Trash is empty</p>';
            return;
        }

        this.trashContentsEl.innerHTML = '';
        for (const item of this.trash) {
            const div = document.createElement('div');
            div.className = `file-item ${item.item.type}`;
            div.textContent = item.name;
            this.trashContentsEl.appendChild(div);
        }
    }

    reset() {
        this.filesystem = this.createInitialFilesystem();
        this.trash = [];
        this.clearTerminal();
        this.renderFiletree();
        this.renderTrash();
        this.addOutputLine('Demo reset. Type a command to begin.');
    }
}

// Initialize demo when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new SRMDemo();
});
