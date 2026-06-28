import { useState, useEffect } from 'react';
import Phone3D from './components/Phone3D';

// SVG Icons (Custom, clean, Lucide-like vectors)
const Icons = {
  Logo: () => (
    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" className="filter drop-shadow-[0_2px_4px_rgba(99,102,241,0.25)]">
      <rect width="24" height="24" rx="6" fill="url(#logo-grad)" />
      <path d="M7 16V8L10 12L13 8V16" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M17 9L15 11.5M17 9L19 11.5M17 9V15" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
      <defs>
        <linearGradient id="logo-grad" x1="0" y1="0" x2="24" y2="24" gradientUnits="userSpaceOnUse">
          <stop stopColor="#6366F1" />
          <stop offset="1" stopColor="#4F46E5" />
        </linearGradient>
      </defs>
    </svg>
  ),
  Search: () => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="11" cy="11" r="8" />
      <path d="M21 21L16.65 16.65" />
    </svg>
  ),
  Download: () => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
      <polyline points="7 10 12 15 17 10" />
      <line x1="12" x2="12" y1="15" y2="3" />
    </svg>
  ),
  Github: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" />
      <path d="M9 18c-4.51 2-5-2-7-2" />
    </svg>
  ),
  ExternalLink: () => (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
      <polyline points="15 3 21 3 21 9" />
      <line x1="10" x2="21" y1="14" y2="3" />
    </svg>
  ),
  Database: () => (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <ellipse cx="12" cy="5" rx="9" ry="3" />
      <path d="M3 5V19A9 3 0 0 0 21 19V5" />
      <path d="M3 12A9 3 0 0 0 21 12" />
    </svg>
  ),
  Cpu: () => (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="4" y="4" width="16" height="16" rx="2" />
      <rect x="9" y="9" width="6" height="6" rx="1" />
      <path d="M9 1v3M15 1v3M9 20v3M15 20v3M20 9h3M20 15h3M1 9h3M1 15h3" />
    </svg>
  ),
  FileCode: () => (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z" />
      <path d="M14 2v4a2 2 0 0 0 2 2h4" />
      <path d="m10 13-2 2 2 2" />
      <path d="m14 17 2-2-2-2" />
    </svg>
  ),
  Pdf: () => (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z" />
      <path d="M14 2v4a2 2 0 0 0 2 2h4" />
      <path d="M10 12h2a2 2 0 1 0 0-4h-2v8" />
    </svg>
  ),
  Sun: () => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="4" />
      <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" />
    </svg>
  ),
  Moon: () => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
    </svg>
  )
};

// Initial Markdown content with rich formatting, tags, and features to demo
const initialMarkdown = `# NustaMD — Simply Markdown

Welcome to **NustaMD**! A high-performance, distraction-free markdown reader. Type on the left and see it render in real-time.

## ✨ High-Performance Features
- **Instant Picking**: Open large \`.md\` files instantly.
- **State Engine**: Powered by Flutter Riverpod for reactive UI.
- **Local Storage**: Hive local database stores history and settings.
- **Clean PDF Exporter**: Turn notes into clean PDFs. Try the **PDF view** toggle!
- **In-Document Search**: Match any word. Enter a term in the search bar above to see highlights.

### 🛠️ Flutter Code Snippet
\`\`\`dart
void main() {
  // Rapid file parsing
  final parser = MarkdownParser();
  print("NustaMD: Ready to render!");
}
\`\`\`

- [x] State management configured (Riverpod)
- [x] In-document highlights working
- [ ] Export to PDF completed
`;

function App() {
  const [theme, setTheme] = useState('dark');
  const [markdown, setMarkdown] = useState(initialMarkdown);
  const [searchQuery, setSearchQuery] = useState('');
  const [platform, setPlatform] = useState('android');
  const [showPdfView, setShowPdfView] = useState(false);
  const [searchMatchesCount, setSearchMatchesCount] = useState(0);
  const [activeSection, setActiveSection] = useState('home'); // 'home', 'features', 'playground', 'architecture'

  // Apply theme class to html element
  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'light') {
      root.classList.add('light-theme');
    } else {
      root.classList.remove('light-theme');
    }
  }, [theme]);

  // Compute Search Matches count
  useEffect(() => {
    if (!searchQuery) {
      setSearchMatchesCount(0);
      return;
    }
    try {
      const escapedQuery = searchQuery.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const regex = new RegExp(escapedQuery, 'gi');
      const matches = markdown.match(regex);
      setSearchMatchesCount(matches ? matches.length : 0);
    } catch (e) {
      setSearchMatchesCount(0);
    }
  }, [searchQuery, markdown]);

  // Highlight Text Utility
  const renderHighlightedText = (text) => {
    if (!searchQuery) return text;
    try {
      const escapedQuery = searchQuery.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const parts = text.split(new RegExp(`(${escapedQuery})`, 'gi'));
      return parts.map((part, index) => 
        part.toLowerCase() === searchQuery.toLowerCase() ? (
          <mark key={index} className="search-highlight">{part}</mark>
        ) : part
      );
    } catch (e) {
      return text;
    }
  };

  // Simple live Markdown parser for high-fidelity React display
  const parseMarkdown = (mdText) => {
    const lines = mdText.split('\n');
    let inCodeBlock = false;
    let codeContent = [];
    const elements = [];

    lines.forEach((line, lineIdx) => {
      // Code block handling
      if (line.trim().startsWith('```')) {
        if (inCodeBlock) {
          inCodeBlock = false;
          elements.push(
            <pre key={`code-${lineIdx}`} className="my-4 p-4 text-xs font-mono bg-brand-code-bg rounded border border-brand-card-border overflow-x-auto text-brand-text">
              <code>{codeContent.join('\n')}</code>
            </pre>
          );
          codeContent = [];
        } else {
          inCodeBlock = true;
        }
        return;
      }

      if (inCodeBlock) {
        codeContent.push(line);
        return;
      }

      const trimmed = line.trim();

      // Headers
      if (trimmed.startsWith('# ')) {
        elements.push(
          <h1 key={lineIdx} className="text-2xl font-bold mt-4 mb-3 pb-1 border-b border-brand-card-border text-brand-text">
            {renderHighlightedText(trimmed.substring(2))}
          </h1>
        );
      } else if (trimmed.startsWith('## ')) {
        elements.push(
          <h2 key={lineIdx} className="text-xl font-bold mt-5 mb-2.5 text-brand-text">
            {renderHighlightedText(trimmed.substring(3))}
          </h2>
        );
      } else if (trimmed.startsWith('### ')) {
        elements.push(
          <h3 key={lineIdx} className="text-lg font-bold mt-4 mb-2 text-brand-text">
            {renderHighlightedText(trimmed.substring(4))}
          </h3>
        );
      }
      // Checkboxes
      else if (trimmed.startsWith('- [ ] ') || trimmed.startsWith('- [x] ')) {
        const isChecked = trimmed.startsWith('- [x] ');
        elements.push(
          <div key={lineIdx} className="flex items-center gap-2 mb-1.5 text-sm">
            <input type="checkbox" checked={isChecked} readOnly className="accent-brand-cta cursor-pointer w-4 h-4" />
            <span className={isChecked ? 'line-through text-brand-text-muted' : 'text-brand-text'}>
              {renderHighlightedText(trimmed.substring(6))}
            </span>
          </div>
        );
      }
      // List items
      else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        elements.push(
          <li key={lineIdx} className="text-sm ml-5 list-disc mb-1 text-brand-text">
            {renderHighlightedText(trimmed.substring(2))}
          </li>
        );
      }
      // Blockquotes
      else if (trimmed.startsWith('> ')) {
        elements.push(
          <blockquote key={lineIdx} className="border-l-4 border-brand-cta pl-4 italic my-4 text-brand-text-muted">
            {renderHighlightedText(trimmed.substring(2))}
          </blockquote>
        );
      }
      // Blank Line
      else if (trimmed === '') {
        elements.push(<div key={lineIdx} className="h-3" />);
      }
      // Paragraph text
      else {
        const parts = line.split(/(\*\*.*?\*\*)/g);
        const parsedLine = parts.map((part, pIdx) => {
          if (part.startsWith('**') && part.endsWith('**')) {
            return <strong key={pIdx} className="font-bold text-brand-text">{renderHighlightedText(part.slice(2, -2))}</strong>;
          }
          const subParts = part.split(/(`.*?`)/g);
          return subParts.map((subPart, sIdx) => {
            if (subPart.startsWith('`') && subPart.endsWith('`')) {
              return <code key={`${pIdx}-${sIdx}`} className="bg-brand-code-bg text-brand-cta font-mono text-xs px-1.5 py-0.5 rounded border border-brand-card-border">{renderHighlightedText(subPart.slice(1, -1))}</code>;
            }
            return renderHighlightedText(subPart);
          });
        });
        elements.push(<p key={lineIdx} className="text-sm mb-2.5 leading-relaxed text-slate-300 light-theme:text-brand-text-muted">{parsedLine}</p>);
      }
    });

    return elements;
  };

  return (
    <div className="flex flex-col min-h-screen bg-brand-bg text-brand-text selection:bg-brand-cta/30 selection:text-white transition-colors duration-300">
      
      {/* Navigation Header */}
      <header className="sticky top-0 z-50 backdrop-blur-md bg-brand-bg/80 border-b border-brand-card-border transition-colors duration-300">
        <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3 font-extrabold text-2xl tracking-tight text-brand-text cursor-pointer">
            <Icons.Logo />
            <span>NustaMD</span>
          </div>
          <nav className="flex items-center gap-6">
            <a href="#features" className="hidden md:inline text-brand-text-muted hover:text-brand-text font-medium text-sm transition-colors duration-150 cursor-pointer">Features</a>
            <a href="#playground" className="hidden md:inline text-brand-text-muted hover:text-brand-text font-medium text-sm transition-colors duration-150 cursor-pointer">Live Demo</a>
            <a href="#architecture" className="hidden md:inline text-brand-text-muted hover:text-brand-text font-medium text-sm transition-colors duration-150 cursor-pointer">Architecture</a>
            <a href="https://github.com/YadneshTeli/MarkDown-Viewer" target="_blank" rel="noopener noreferrer" className="text-brand-text-muted hover:text-brand-text transition-colors duration-150 cursor-pointer flex items-center" aria-label="GitHub Repository">
              <Icons.Github />
            </a>
            <button 
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')} 
              className="p-2.5 rounded-full cursor-pointer bg-brand-card-bg border border-brand-card-border hover:border-brand-cta text-brand-text hover:text-brand-cta transition-colors duration-150"
              aria-label="Toggle Theme"
            >
              {theme === 'dark' ? <Icons.Sun /> : <Icons.Moon />}
            </button>
          </nav>
        </div>
      </header>

      {/* Hero Section */}
      <section className="max-w-7xl mx-auto px-6 py-16 md:py-24 lg:py-32 w-full">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-16 items-center">
          <div className="lg:col-span-7 flex flex-col items-start gap-6 text-left">
            <span className="inline-block text-[11px] font-bold tracking-widest text-brand-primary bg-brand-primary/10 border border-brand-primary/25 px-3 py-1 rounded-full uppercase">
              Flutter Markdown App
            </span>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black leading-tight tracking-tight text-brand-text">
              Markdown, <span className="bg-gradient-to-r from-brand-primary to-brand-cta bg-clip-text text-transparent font-heading">Beautifully Rendered</span>. Instantly.
            </h1>
            <p className="text-lg sm:text-xl text-brand-text-muted leading-relaxed max-w-xl">
              An elegant cross-platform mobile and desktop Markdown viewer built in Flutter. Explore, edit, search highlights, and print to paginated PDF.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
              <a 
                href="#playground" 
                className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-lg bg-brand-primary hover:bg-brand-primary/95 text-white font-semibold text-sm hover:translate-y-[-2px] hover:shadow-[0_4px_12px_rgba(99,102,241,0.4)] active:translate-y-0 transition-all duration-200 cursor-pointer text-center"
              >
                <span>Launch Live Demo</span>
              </a>
              <a 
                href="https://github.com/YadneshTeli/MarkDown-Viewer/releases/latest" 
                target="_blank" 
                rel="noopener noreferrer" 
                className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-lg bg-brand-card-bg hover:bg-brand-card-bg/90 border border-brand-card-border text-brand-text font-semibold text-sm hover:translate-y-[-2px] active:translate-y-0 transition-all duration-200 cursor-pointer"
              >
                <Icons.Download />
                <span>Download App</span>
              </a>
            </div>
          </div>
          <div className="lg:col-span-5 flex justify-center relative w-full">
            <div className="relative w-full max-w-sm">
              <div className="absolute -top-6 -left-6 w-24 h-24 rounded-full bg-brand-cta/20 blur-xl animate-float-slow"></div>
              <div className="absolute -bottom-8 -right-4 w-32 h-32 rounded-full bg-brand-primary/20 blur-2xl animate-float-slow-reverse"></div>
              
              <div className="w-full relative z-10">
                <Phone3D markdown={markdown} theme={theme} />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Bento Grid Features Section */}
      <section id="features" className="max-w-7xl mx-auto px-6 py-20 border-t border-brand-card-border w-full">
        <div className="text-center mb-16">
          <span className="text-xs font-bold tracking-widest text-brand-cta uppercase">Bento Grid Showcase</span>
          <h2 className="text-3xl sm:text-4xl font-extrabold mt-2 mb-4 tracking-tight text-brand-text">Engineered For Content Reading</h2>
          <p className="text-base sm:text-lg text-brand-text-muted max-w-2xl mx-auto">A simple markdown reader configured with developer-centric performance utilities.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Card 1: Local History */}
          <div className="md:col-span-2 group bg-brand-card-bg border border-brand-card-border rounded-2xl p-6 shadow-lg hover:border-brand-cta hover:shadow-2xl transition-all duration-300 hover:-translate-y-1 backdrop-blur-md relative overflow-hidden cursor-pointer flex flex-col justify-between" tabIndex="0">
            <div>
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-brand-primary border border-brand-card-border text-brand-cta mb-6 group-hover:bg-brand-cta group-hover:text-brand-bg transition-all duration-300">
                <Icons.Database />
              </div>
              <h3 className="text-xl font-bold text-brand-text mb-2">Persistent File History</h3>
              <p className="text-sm text-brand-text-muted leading-relaxed mb-6">
                NustaMD integrates Hive Local Cache to track and remember your open documents. Reopen any recently accessed files instantly without triggering native file picker dialogs.
              </p>
            </div>
            <div className="flex flex-col gap-2 bg-slate-950/40 border border-brand-card-border p-3 rounded-lg">
              <div className="flex items-center gap-3 px-3 py-2 rounded-md font-mono text-xs text-brand-text hover:bg-white/5 transition-colors">
                <span className="w-1.5 h-1.5 rounded-full bg-brand-cta"></span>
                <span className="flex-grow text-brand-text">architecture_notes.md</span>
                <span className="text-[10px] text-brand-text-muted">2m ago</span>
              </div>
              <div className="flex items-center gap-3 px-3 py-2 rounded-md font-mono text-xs text-brand-text hover:bg-white/5 transition-colors">
                <span className="w-1.5 h-1.5 rounded-full bg-brand-text-muted"></span>
                <span className="flex-grow text-brand-text">release_v1_specs.markdown</span>
                <span className="text-[10px] text-brand-text-muted">1h ago</span>
              </div>
              <div className="flex items-center gap-3 px-3 py-2 rounded-md font-mono text-xs text-brand-text hover:bg-white/5 transition-colors">
                <span className="w-1.5 h-1.5 rounded-full bg-brand-text-muted"></span>
                <span className="flex-grow text-brand-text">todo_list.md</span>
                <span className="text-[10px] text-brand-text-muted">Yesterday</span>
              </div>
            </div>
          </div>

          {/* Card 2: State Engine */}
          <div className="md:col-span-1 group bg-brand-card-bg border border-brand-card-border rounded-2xl p-6 shadow-lg hover:border-brand-cta hover:shadow-2xl transition-all duration-300 hover:-translate-y-1 backdrop-blur-md relative overflow-hidden cursor-pointer flex flex-col justify-between" tabIndex="0">
            <div>
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-brand-primary border border-brand-card-border text-brand-cta mb-6 group-hover:bg-brand-cta group-hover:text-brand-bg transition-all duration-300">
                <Icons.Cpu />
              </div>
              <h3 className="text-xl font-bold text-brand-text mb-2">Riverpod State Engine</h3>
              <p className="text-sm text-brand-text-muted leading-relaxed mb-6">
                State transitions are managed reactively via AsyncNotifier, updating layouts and indexing search terms with zero locks.
              </p>
            </div>
          </div>

          {/* Card 3: In-Document Search */}
          <div className="md:col-span-1 group bg-brand-card-bg border border-brand-card-border rounded-2xl p-6 shadow-lg hover:border-brand-cta hover:shadow-2xl transition-all duration-300 hover:-translate-y-1 backdrop-blur-md relative overflow-hidden cursor-pointer flex flex-col justify-between" tabIndex="0">
            <div>
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-brand-primary border border-brand-card-border text-brand-cta mb-6 group-hover:bg-brand-cta group-hover:text-brand-bg transition-all duration-300">
                <Icons.Search />
              </div>
              <h3 className="text-xl font-bold text-brand-text mb-2">Interactive Match Highlights</h3>
              <p className="text-sm text-brand-text-muted leading-relaxed mb-6">
                Instantly index document nodes and highlight query matches in real-time as you type, complete with occurrence count metrics.
              </p>
            </div>
          </div>

          {/* Card 4: SVG Render */}
          <div className="md:col-span-2 group bg-brand-card-bg border border-brand-card-border rounded-2xl p-6 shadow-lg hover:border-brand-cta hover:shadow-2xl transition-all duration-300 hover:-translate-y-1 backdrop-blur-md relative overflow-hidden cursor-pointer flex flex-col justify-between" tabIndex="0">
            <div>
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-brand-primary border border-brand-card-border text-brand-cta mb-6 group-hover:bg-brand-cta group-hover:text-brand-bg transition-all duration-300">
                <Icons.FileCode />
              </div>
              <h3 className="text-xl font-bold text-brand-text mb-2">Shields.io Badges & SVG Support</h3>
              <p className="text-sm text-brand-text-muted leading-relaxed mb-6">
                Auto-parsing filters SVG vector images and converts Shields.io badge elements to render clearly, ensuring README files present exactly as designed on GitHub.
              </p>
            </div>
            <div className="flex gap-2.5 flex-wrap mt-4">
              <span className="font-sans text-[10px] font-semibold py-1 px-2.5 rounded text-white bg-sky-600">build | passing</span>
              <span className="font-sans text-[10px] font-semibold py-1 px-2.5 rounded text-white bg-emerald-600">dependencies | up to date</span>
              <span className="font-sans text-[10px] font-semibold py-1 px-2.5 rounded text-white bg-violet-600">license | MIT</span>
            </div>
          </div>
        </div>
      </section>

      {/* Interactive Live Playground Section */}
      <section id="playground" className="max-w-7xl mx-auto px-6 py-20 border-t border-brand-card-border w-full">
        <div className="text-center mb-12">
          <span className="text-xs font-bold tracking-widest text-brand-cta uppercase">Interactive Playground</span>
          <h2 className="text-3xl sm:text-4xl font-extrabold mt-2 mb-4 tracking-tight text-brand-text">See It Render In Action</h2>
          <p className="text-base sm:text-lg text-brand-text-muted max-w-2xl mx-auto">Experience real-time parsing, device-adaptive layouts, and live in-document search matching.</p>
        </div>

        {/* Playground controls */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4 w-full flex-shrink-0">
          <div className="flex items-center gap-2.5 flex-wrap">
            <span className="text-sm font-semibold text-brand-text-muted">Device Layout Frame:</span>
            <button 
              onClick={() => { setPlatform('android'); setShowPdfView(false); }} 
              className={`px-3.5 py-1.5 text-xs font-semibold rounded-lg bg-brand-card-bg border border-brand-card-border hover:text-brand-text hover:border-brand-text-muted transition-colors cursor-pointer ${platform === 'android' && !showPdfView ? 'bg-brand-cta text-brand-bg border-brand-cta font-bold' : 'text-brand-text-muted'}`}
            >
              Android
            </button>
            <button 
              onClick={() => { setPlatform('ios'); setShowPdfView(false); }} 
              className={`px-3.5 py-1.5 text-xs font-semibold rounded-lg bg-brand-card-bg border border-brand-card-border hover:text-brand-text hover:border-brand-text-muted transition-colors cursor-pointer ${platform === 'ios' && !showPdfView ? 'bg-brand-cta text-brand-bg border-brand-cta font-bold' : 'text-brand-text-muted'}`}
            >
              iOS
            </button>
            <button 
              onClick={() => { setPlatform('desktop'); setShowPdfView(false); }} 
              className={`px-3.5 py-1.5 text-xs font-semibold rounded-lg bg-brand-card-bg border border-brand-card-border hover:text-brand-text hover:border-brand-text-muted transition-colors cursor-pointer ${platform === 'desktop' && !showPdfView ? 'bg-brand-cta text-brand-bg border-brand-cta font-bold' : 'text-brand-text-muted'}`}
            >
              Desktop
            </button>
          </div>

          <div>
            <button 
              onClick={() => setShowPdfView(!showPdfView)} 
              className={`flex items-center gap-2 text-xs px-4 py-1.5 rounded-lg border hover:bg-rose-500/10 hover:border-rose-500/40 hover:text-rose-500 transition-all cursor-pointer ${showPdfView ? 'bg-rose-600 text-white border-rose-600 font-bold shadow-lg shadow-rose-600/30' : 'bg-brand-card-bg border-brand-card-border text-brand-text'}`}
            >
              <Icons.Pdf />
              <span>{showPdfView ? 'Exit PDF View' : 'Try PDF Print Preview'}</span>
            </button>
          </div>
        </div>

        {/* Live Playground Canvas */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[60vh] min-h-[450px] max-h-[650px] border border-brand-card-border rounded-2xl overflow-hidden bg-brand-bg/25 w-full">
          {/* Left panel: Editor */}
          <div className="flex flex-col border-b lg:border-b-0 lg:border-r border-brand-card-border h-full">
            <div className="px-4 py-3 bg-brand-bg/40 border-b border-brand-card-border flex items-center min-h-[48px]">
              <span className="text-[10px] font-bold uppercase tracking-wider text-brand-text-muted">Editor (Markdown Input)</span>
            </div>
            <textarea 
              value={markdown} 
              onChange={(e) => setMarkdown(e.target.value)} 
              placeholder="Type your markdown here..."
              className="flex-grow w-full bg-transparent resize-none p-4 font-mono text-sm text-brand-text outline-none focus:ring-0"
              spellCheck="false"
            />
          </div>

          {/* Right panel: Live Preview */}
          <div className="flex flex-col h-full">
            <div className="px-4 py-3 bg-brand-bg/40 border-b border-brand-card-border flex justify-between items-center min-h-[48px] gap-4">
              <span className="text-[10px] font-bold uppercase tracking-wider text-brand-text-muted">Viewer Output</span>
              
              {/* In-Document Search Mock */}
              <div className="flex items-center gap-2 bg-brand-code-bg border border-brand-card-border px-3 py-1 rounded-lg text-brand-text-muted w-40 sm:w-48 focus-within:w-56 focus-within:border-brand-cta focus-within:text-brand-text transition-all duration-200 relative">
                <Icons.Search />
                <input 
                  type="text" 
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search document..." 
                  className="bg-transparent border-none outline-none text-xs text-brand-text w-full pr-12"
                  aria-label="Search content"
                />
                {searchQuery && (
                  <span className="text-[9px] font-bold bg-brand-cta text-slate-900 px-1 rounded absolute right-2 top-1/2 -translate-y-1/2">
                    {searchMatchesCount}
                  </span>
                )}
              </div>
            </div>

            {/* Container for device mockup frames */}
            <div className="flex-grow p-6 overflow-y-auto flex justify-center items-start bg-black/10 dark:bg-black/20 light-theme:bg-slate-200/40">
              {showPdfView ? (
                /* Paginated A4 mockups for PDF exporting */
                <div className="pdf-paper bg-white text-slate-800 shadow-2xl p-8 w-full max-w-[420px] min-h-[480px] font-serif flex flex-col text-xs text-left">
                  <div className="border-b border-slate-300 pb-1 mb-3 flex justify-between font-sans text-[9px] text-slate-500 uppercase">
                    <span>NustaMD Export Document</span>
                    <span>Page 1 of 1</span>
                  </div>
                  <div className="markdown-body bg-transparent flex-grow">
                    {parseMarkdown(markdown)}
                  </div>
                </div>
              ) : (
                /* Device frames */
                <div className={`w-full ${platform === 'desktop' ? 'max-w-xl h-full' : platform === 'ios' ? 'max-w-[280px] h-full max-h-[90%]' : 'max-w-[280px] h-full max-h-[90%]'} border-4 ${theme === 'dark' ? 'border-slate-800' : 'border-slate-300'} rounded-[32px] overflow-hidden shadow-2xl bg-slate-900 flex flex-col relative transition-all duration-300`}>
                  
                  {/* Platform header */}
                  <div className={`px-4 py-2 flex justify-between items-center text-xs flex-shrink-0 ${platform === 'android' ? 'bg-[#6366F1] text-white' : 'bg-slate-950 text-slate-400 border-b border-slate-800'}`}>
                    {platform !== 'desktop' && <span className="cursor-pointer">←</span>}
                    <span className="font-semibold text-xs truncate max-w-[150px]">readme.md</span>
                    <span className="cursor-pointer font-bold">⋮</span>
                  </div>

                  <div className="p-4 overflow-y-auto flex-grow markdown-body bg-slate-900 dark:bg-slate-900 light-theme:bg-white text-left">
                    {parseMarkdown(markdown)}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Architecture & Tech Specs section */}
      <section id="architecture" className="max-w-7xl mx-auto px-6 py-20 border-t border-brand-card-border w-full text-left">
        <div className="text-center mb-12">
          <span className="text-xs font-bold tracking-widest text-brand-cta uppercase">Technical Core</span>
          <h2 className="text-3xl sm:text-4xl font-extrabold mt-2 mb-4 tracking-tight text-brand-text">App Architecture & Libraries</h2>
          <p className="text-base sm:text-lg text-brand-text-muted max-w-2xl mx-auto">A clean modular structure designed to run lightweight logic on client devices.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 mt-8">
          <div className="bg-brand-card-bg border border-brand-card-border p-6 rounded-2xl backdrop-blur-md">
            <h3 className="text-xl font-bold mb-4 text-brand-text">Directory Architecture</h3>
            <div className="font-mono text-sm leading-relaxed text-brand-text">
              <div className="py-0.5 text-brand-primary font-bold">📂 lib/</div>
              <div className="py-0.5 pl-5 text-brand-text-muted">📂 models/ <span className="text-xs text-brand-text-muted/60">// Hive TypeAdapters</span></div>
              <div className="py-0.5 pl-10">📄 markdown_file.dart</div>
              <div className="py-0.5 pl-5 text-brand-text-muted">📂 providers/ <span className="text-xs text-brand-text-muted/60">// Riverpod Notifiers</span></div>
              <div className="py-0.5 pl-10">📄 markdown_notifier.dart</div>
              <div className="py-0.5 pl-10">📄 search_notifier.dart</div>
              <div className="py-0.5 pl-10">📄 theme_notifier.dart</div>
              <div className="py-0.5 pl-5 text-brand-text-muted">📂 views/ <span className="text-xs text-brand-text-muted/60">// Adaptive UI layouts</span></div>
              <div className="py-0.5 pl-10">📄 home_view.dart</div>
              <div className="py-0.5 pl-10">📄 playground_view.dart</div>
              <div className="py-0.5 pl-10 text-brand-text-muted">📂 components/</div>
              <div className="py-0.5 pl-15">📄 markdown_renderer.dart</div>
              <div className="py-0.5 pl-15">📄 search_overlay.dart</div>
              <div className="py-0.5 pl-5 text-brand-text-muted">📂 utils/ <span className="text-xs text-brand-text-muted/60">// PDF print exporter API</span></div>
              <div className="py-0.5 pl-10">📄 pdf_exporter.dart</div>
            </div>
          </div>

          <div className="bg-brand-card-bg border border-brand-card-border p-6 rounded-2xl backdrop-blur-md flex flex-col justify-between">
            <div>
              <h3 className="text-xl font-bold mb-4 text-brand-text">Performance Packages</h3>
              <div className="flex flex-col gap-4">
                <div className="flex justify-between items-center border-b border-brand-card-border pb-2">
                  <div>
                    <span className="font-semibold text-base block">flutter_riverpod</span>
                    <span className="text-xs text-brand-text-muted">State engine with zero rebuild overhead</span>
                  </div>
                  <span className="font-mono text-sm text-brand-cta">^2.5.1</span>
                </div>
                <div className="flex justify-between items-center border-b border-brand-card-border pb-2">
                  <div>
                    <span className="font-semibold text-base block">hive_flutter</span>
                    <span className="text-xs text-brand-text-muted">Fast NoSQL database cache</span>
                  </div>
                  <span className="font-mono text-sm text-brand-cta">^1.1.0</span>
                </div>
                <div className="flex justify-between items-center border-b border-brand-card-border pb-2">
                  <div>
                    <span className="font-semibold text-base block">markdown_widget</span>
                    <span className="text-xs text-brand-text-muted">Adaptive rendering layouts</span>
                  </div>
                  <span className="font-mono text-sm text-brand-cta">^2.3.3</span>
                </div>
                <div className="flex justify-between items-center">
                  <div>
                    <span className="font-semibold text-base block">pdf / printing</span>
                    <span className="text-xs text-brand-text-muted">High contrast A4 print compiler</span>
                  </div>
                  <span className="font-mono text-sm text-brand-cta">^3.10.4</span>
                </div>
              </div>
            </div>

            <div className="mt-6 pt-4 border-t border-brand-card-border flex justify-between items-center">
              <span className="text-xs font-bold text-brand-text-muted uppercase tracking-wider">License:</span>
              <span className="px-2.5 py-1 rounded text-xs font-bold text-emerald-400 bg-emerald-400/10 border border-emerald-400/25">MIT Approved</span>
            </div>
          </div>
        </div>
      </section>

      {/* Floating CTA / Download Sticky Bar */}
      <section className="bg-brand-primary border-t border-b border-brand-card-border py-8 px-6 w-full">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-6">
          <div className="text-center md:text-left">
            <h4 className="text-xl sm:text-2xl font-bold mb-1 text-white">Ready to try NustaMD?</h4>
            <p className="text-indigo-200 text-sm sm:text-base">Download the latest platform application packages directly from GitHub releases.</p>
          </div>
          <div className="w-full md:w-auto">
            <a 
              href="https://github.com/YadneshTeli/MarkDown-Viewer/releases/latest" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-lg bg-brand-cta hover:bg-brand-cta-hover text-brand-bg font-semibold text-sm hover:translate-y-[-2px] hover:shadow-[0_4px_12px_rgba(6,182,212,0.4)] active:translate-y-0 transition-all duration-200 cursor-pointer w-full md:w-auto"
            >
              <Icons.Download />
              <span>Download Latest Release</span>
            </a>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-brand-card-border py-12 px-6 bg-brand-bg/40 w-full mt-auto">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-brand-text-muted text-center md:text-left">
          <p>© 2026 NustaMD. Open source project under MIT License.</p>
          <div className="flex gap-6 items-center flex-wrap justify-center font-medium">
            <span>Developed by <strong>Yadnesh Teli</strong></span>
            <a href="https://linkedin.com/in/yadneshteli" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1 hover:text-brand-cta transition-colors">
              LinkedIn <Icons.ExternalLink />
            </a>
            <a href="https://github.com/YadneshTeli" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1 hover:text-brand-cta transition-colors">
              GitHub <Icons.ExternalLink />
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;
