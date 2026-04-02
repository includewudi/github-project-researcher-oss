# Step 3: Architecture Analysis

> **Open when:** Complex project where understanding design is critical.

## Identify Design Patterns

**Adapt to detected language:**

### Python
```bash
find . -name "__init__.py" -o -name "base.py" -o -name "core.py" | head -20
grep -r "class.*:" --include="*.py" . | grep -E "(Base|Abstract|Interface|Mixin)" | head -20
grep -r "register\|factory\|provider\|create_" --include="*.py" . | head -20
```

### TypeScript
```bash
find . -name "index.ts" -o -name "main.ts" | grep -v node_modules | head -20
grep -r "class.*extends\|implements" --include="*.ts" . | grep -v node_modules | head -20
grep -r "createFactory\|Provider\|useContext\|createContext" --include="*.ts" . | grep -v node_modules | head -20
```

### Go
```bash
find . -name "main.go" -o -name "cmd" -type d | grep -v vendor | head -20
grep -r "type.*interface {" --include="*.go" . | grep -v vendor | head -20
grep -r "func New\|func Create" --include="*.go" . | grep -v vendor | head -20
```

## Common Patterns

| Pattern | How to Detect |
|---------|---------------|
| **Provider/Registry** | `register()`, global registry dict |
| **Template Method** | Base class with abstract methods |
| **Factory** | `create_*()`, `build_*()` |
| **Strategy** | Interchangeable implementations |
| **Decorator** | Wrapper classes, delegation |
| **Expression Engine** | DSL parsing, operator overloading |

## Component Hierarchy (ASCII)

```
Project Architecture
├── Core Layer
│   ├── Component A (path/)
│   │   ├── Sub-component
│   │   └── Sub-component
│   └── Component B (path/)
├── Application Layer
│   └── Feature modules
└── Extension Layer
    └── Plugins / contrib
```

## Extension Points

| Extension | Location | How to Extend |
|-----------|----------|---------------|
| {name} | {path} | {mechanism} |

## Output in RESEARCH.md

```markdown
## Architecture Analysis

### Design Patterns
| Pattern | Location | Purpose |
|---------|----------|---------|

### Component Hierarchy
{ASCII diagram}

### Extension Points
| Extension | Base Class | Example |
|-----------|------------|---------|

### Key Abstractions
- **{Name}**: {purpose and key methods}
```
