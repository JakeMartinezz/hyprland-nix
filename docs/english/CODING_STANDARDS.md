# Coding Standards & Development Guidelines 📋

This document outlines the coding standards, architectural principles, and best practices for the NixOS Configuration Installer project. Following these guidelines ensures maintainability, scalability, and consistency across the codebase.

## 🌐 Internationalization (i18n)

### **Rule 1: Never Hardcode Languages in Output**
All user-facing text MUST be stored in language string variables, never directly in `echo` statements.

#### ❌ **Bad Example:**
```bash
echo "Installing configuration..."
echo "Error: File not found"
```

#### ✅ **Good Example:**
```bash
echo -e "${BLUE}$MSG_INSTALLING_CONFIG${NC}"
echo -e "${RED}$MSG_FILE_NOT_FOUND${NC}"
```

### **Language String Organization**
- **Portuguese strings**: Lines 30-200 in `install.sh`
- **English strings**: Lines 201-400 in `install.sh`
- **Naming convention**: `MSG_ACTION_OBJECT` (e.g., `MSG_DOTFILES_APPLYING`)
- **Consistency**: Both languages must have identical variable names

### **Required Language Support**
- Portuguese (primary)
- English (secondary)
- All new features MUST include both language variants

## 🏗️ Architecture Principles

### **Feature Flag System**
The configuration uses centralized feature flags instead of host-specific configurations:

```nix
# ✅ Good: Feature-based configuration
features = {
  gpu.type = "amd";
  laptop.enable = false;
  gaming.enable = true;
};

# ❌ Bad: Host-specific hardcoding
hosts.desktop = {
  gpu = "amd";
  isLaptop = false;
};
```

### **Modular Design**
- **Single Responsibility**: Each function/module has one clear purpose
- **Separation of Concerns**: System vs Home vs Packages clearly separated
- **Conditional Loading**: Only load modules when features are enabled

### **Data Flow Architecture**
```
variables.nix (source of truth)
    ↓
flake.nix (universal configuration)
    ↓
Conditional modules (based on feature flags)
    ↓
Applied configuration
```

## 🔧 Function Design Patterns

### **Error Handling**
All functions MUST return proper exit codes and handle errors gracefully:

```bash
function_name() {
    # Validate input
    if [[ -z "$required_param" ]]; then
        echo -e "${RED}$MSG_MISSING_PARAM${NC}"
        return 1
    fi
    
    # Perform operation
    if ! some_operation; then
        echo -e "${RED}$MSG_OPERATION_FAILED${NC}"
        return 1
    fi
    
    # Success
    echo -e "${GREEN}$MSG_OPERATION_SUCCESS${NC}"
    return 0
}
```

### **Input Validation**
Always validate user input before processing:

```bash
validate_input() {
    local input="$1"
    local pattern="$2"
    
    if [[ ! "$input" =~ $pattern ]]; then
        echo -e "${RED}$MSG_INVALID_INPUT${NC}"
        return 1
    fi
    
    return 0
}
```

### **Configuration Functions**
Follow the pattern: collect → validate → confirm → apply

```bash
collect_config() {
    # Collect user preferences
}

validate_config() {
    # Validate collected data
}

show_config_review() {
    # Display for user confirmation
}

apply_config() {
    # Apply the configuration
}
```

## 📁 File Structure Standards

### **Directory Organization**
```
project/
├── docs/                    # Documentation only
├── config/                  # Configuration files
├── modules/                 # Modular components
│   ├── home/               # User-specific modules
│   ├── packages/           # Package management
│   └── system/             # System-level modules
└── install.sh              # Main installer script
```

### **File Naming Conventions**
- **Snake case**: `file_name.nix`, `function_name()`
- **Kebab case**: `README.md`, `CODING_STANDARDS.md`
- **Descriptive names**: `gpu.nix` not `g.nix`

## 🎨 Code Style Guidelines

### **Shell Script Style**

#### **Variables**
```bash
# ✅ Good: Descriptive, UPPER_CASE for constants
readonly CONFIG_PATH="/etc/nixos"
local user_choice=""

# ❌ Bad: Unclear, mixed case
cf="/etc/nixos"
Choice=""
```

#### **Functions**
```bash
# ✅ Good: Clear purpose, proper error handling
configure_gpu_drivers() {
    local gpu_type="$1"
    
    case "$gpu_type" in
        "amd"|"nvidia"|"intel")
            echo -e "${GREEN}$MSG_GPU_CONFIGURING $gpu_type${NC}"
            return 0
            ;;
        *)
            echo -e "${RED}$MSG_GPU_UNSUPPORTED${NC}"
            return 1
            ;;
    esac
}

# ❌ Bad: Unclear purpose, no error handling
setup() {
    echo "Setting up..."
}
```

#### **Command Execution**
```bash
# ✅ Good: Proper error checking and user feedback
if sudo nixos-rebuild switch --flake /etc/nixos#default; then
    echo -e "${GREEN}$MSG_REBUILD_SUCCESS${NC}"
else
    echo -e "${RED}$MSG_REBUILD_FAILED${NC}"
    return 1
fi

# ❌ Bad: No error checking
sudo nixos-rebuild switch --flake /etc/nixos#default
```

### **Nix Expression Style**

#### **Feature Flags**
```nix
# ✅ Good: Clear boolean flags with descriptive names
features = {
  gpu = {
    type = "amd";
    amd.enable = true;
    nvidia.enable = false;
  };
  services = {
    virtualbox.enable = true;
    fauxmo.enable = false;
  };
};

# ❌ Bad: Mixed types, unclear structure
config = {
  gpu = "amd";
  vbox = 1;
  alexa = "no";
};
```

## 📊 Data Management

### **Configuration Storage**
- **Source of Truth**: `config/variables.nix`
- **Temporary Data**: `/tmp/nixos_*` files
- **Persistent Presets**: `preset.conf` with Base64 encoding
- **No Hardcoded Paths**: Use variables for all paths

### **State Management**
```bash
# ✅ Good: Clear state tracking
prepare_operation() {
    echo "$operation_data" > /tmp/nixos_operation_state
}

apply_operation() {
    if [[ -f /tmp/nixos_operation_state ]]; then
        local operation_data
        operation_data=$(cat /tmp/nixos_operation_state)
        # Process operation
        rm -f /tmp/nixos_operation_state
    fi
}

# ❌ Bad: Global variables, unclear state
GLOBAL_STATE=""
```

## 🔄 User Experience Standards

### **Interactive Flow**
1. **Clear Introduction**: Explain what the script will do
2. **Step-by-Step**: Break complex operations into clear steps
3. **Confirmation**: Always confirm before destructive operations
4. **Progress Feedback**: Show progress during long operations
5. **Error Recovery**: Provide clear error messages and recovery options

### **User Input Validation**
```bash
ask_yes_no() {
    local prompt="$1"
    local default="$2"
    local response
    
    while true; do
        read -p "$prompt " response
        case "${response:-$default}" in
            [Yy]|[Yy][Ee][Ss]) echo "true"; return 0 ;;
            [Nn]|[Nn][Oo]) echo "false"; return 0 ;;
            *) echo -e "${RED}$MSG_INVALID_CHOICE${NC}" ;;
        esac
    done
}
```

### **Progress Indication**
```bash
# ✅ Good: Clear progress indicators
echo -e "${BLUE}🔄 $MSG_OPERATION_STARTING${NC}"
perform_operation
echo -e "${GREEN}✅ $MSG_OPERATION_COMPLETE${NC}"

# ❌ Bad: Silent operations
perform_operation
```

## 🧪 Testing Standards

### **Manual Testing Checklist**
- [ ] Test both Portuguese and English interfaces
- [ ] Test all GPU types (AMD, NVIDIA, Intel)
- [ ] Test laptop and desktop configurations
- [ ] Test with and without additional disks
- [ ] Test preset save/load functionality
- [ ] Test dotfiles integration
- [ ] Test error conditions and recovery

### **Validation Requirements**
- All user inputs must be validated
- All file operations must check for existence/permissions
- All system commands must check exit codes
- All network operations must handle timeouts

## 🚀 Performance Guidelines

### **Efficient Operations**
```bash
# ✅ Good: Efficient file operations
if [[ -f "$file" ]]; then
    content=$(cat "$file")
fi

# ❌ Bad: Unnecessary operations
content=$(cat "$file" 2>/dev/null || echo "")
```

### **Resource Management**
- Clean up temporary files after use
- Use appropriate timeouts for network operations
- Minimize system command execution
- Cache expensive operations when possible

## 🔐 Security Considerations

### **Input Sanitization**
```bash
# ✅ Good: Sanitize user input
sanitize_path() {
    local path="$1"
    # Remove dangerous characters
    path=$(echo "$path" | sed 's/[;&|`$<>]//g')
    echo "$path"
}

# ❌ Bad: Direct use of user input
sudo rm -rf "$user_input"
```

### **File Permissions**
- Always set proper ownership after creating system files
- Use `sudo` only when necessary
- Validate file paths before operations
- Never execute user-provided code directly

## 📚 Documentation Requirements

### **Code Comments**
```bash
# ✅ Good: Explains why, not what
# Redirect UI messages to stderr to avoid capture in variable assignment
echo -e "${YELLOW}$MSG_MOUNT_OPTIONS${NC}" >&2

# ❌ Bad: States the obvious
# Print message
echo -e "${YELLOW}$MSG_MOUNT_OPTIONS${NC}"
```

### **Function Documentation**
```bash
# Configure GPU drivers based on detected hardware
# Args:
#   $1: GPU type (amd|nvidia|intel)
# Returns:
#   0: Success
#   1: Unsupported GPU type or configuration error
configure_gpu_drivers() {
    # Implementation
}
```

## 🔧 Maintenance Guidelines

### **Version Control**
- Use conventional commit messages with emojis
- Include both Portuguese and English in commit descriptions
- Reference issue numbers when applicable
- Use semantic versioning for releases

### **Backward Compatibility**
- Maintain compatibility with existing presets
- Gracefully handle missing configuration options
- Provide migration paths for configuration changes
- Document breaking changes clearly

## 🎯 Future Development Priorities

### **High Priority**
1. **Enhanced Hardware Detection**: Support for more hardware types
2. **Advanced Validation**: More comprehensive system checks
3. **Profile System**: Multiple configuration profiles per user
4. **Remote Configuration**: Support for configuration repositories

### **Medium Priority**
1. **GUI Interface**: Optional graphical installer
2. **Plugin System**: Extensible configuration modules
3. **Automated Updates**: Self-updating installer
4. **Configuration Migration**: Tools for upgrading configurations

### **Low Priority**
1. **Alternative Languages**: Support for additional languages
2. **Cloud Integration**: Cloud storage for configurations
3. **Telemetry**: Optional usage statistics
4. **Advanced Theming**: Customizable installer appearance

## 📝 Code Review Checklist

Before submitting changes, ensure:

- [ ] All strings are internationalized (Portuguese + English)
- [ ] Functions follow error handling patterns
- [ ] User input is properly validated
- [ ] Temporary files are cleaned up
- [ ] Progress feedback is provided for long operations
- [ ] Error messages are helpful and actionable
- [ ] Code follows established naming conventions
- [ ] Security considerations are addressed
- [ ] Documentation is updated if needed
- [ ] Manual testing has been performed

## 🤝 Contributing Guidelines

### **Code Contributions**
1. Follow the coding standards in this document
2. Include both Portuguese and English strings
3. Test thoroughly before submitting
4. Update documentation if needed
5. Use conventional commit format

### **Documentation Contributions**
1. Keep documentation up to date with code changes
2. Use clear, concise language
3. Include practical examples
4. Consider both technical and non-technical users

---

This document should be regularly updated as the project evolves. When adding new features or making significant changes, review and update these standards to ensure they remain relevant and helpful.

**Last Updated**: July 23, 2025  
**Version**: 1.0  
**Authors**: Development Team