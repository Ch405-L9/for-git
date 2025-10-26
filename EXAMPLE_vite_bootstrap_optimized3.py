#!/usr/bin/env python3
"""
CH405 Vite Bootstrap - Fixed Non-Interactive Version
Creates complete minimalist site without npm create vite
"""

import os
import json
import subprocess
from pathlib import Path


class ViteBootstrap:
    def __init__(self, project_name: str):
        self.project_name = project_name
        self.project_path = Path(project_name)
        
    def create_structure(self):
        """Create complete directory structure"""
        print(f"📁 Creating {self.project_name}...")
        
        dirs = [
            "src/components/layout",
            "src/components/sections",
            "src/config",
            "src/styles",
            "public"
        ]
        
        for d in dirs:
            (self.project_path / d).mkdir(parents=True, exist_ok=True)
            
    def generate_package_json(self):
        """Generate package.json with compression plugins"""
        pkg = {
            "name": self.project_name,
            "private": True,
            "version": "0.0.0",
            "type": "module",
            "scripts": {
                "dev": "vite --port 3000",
                "build": "tsc && vite build",
                "preview": "vite preview",
                "lint": "eslint . --ext ts,tsx"
            },
            "dependencies": {
                "react": "^18.2.0",
                "react-dom": "^18.2.0"
            },
            "devDependencies": {
                "@types/react": "^18.2.0",
                "@types/react-dom": "^18.2.0",
                "@typescript-eslint/eslint-plugin": "^6.0.0",
                "@typescript-eslint/parser": "^6.0.0",
                "@vitejs/plugin-react": "^4.2.1",
                "eslint": "^8.45.0",
                "eslint-plugin-react-hooks": "^4.6.0",
                "eslint-plugin-react-refresh": "^0.4.3",
                "typescript": "^5.0.2",
                "vite": "^5.0.0",
                "rollup-plugin-visualizer": "^5.12.0",
                "vite-plugin-compression": "^0.5.1"
            }
        }
        (self.project_path / "package.json").write_text(json.dumps(pkg, indent=2))
        
    def generate_robots_txt(self):
        """Generate robots.txt"""
        content = """User-agent: *
Allow: /
Sitemap: https://yoursite.com/sitemap.xml
"""
        (self.project_path / "public/robots.txt").write_text(content)
        
    def generate_vite_config(self):
        """Generate vite.config.ts from LH97 build"""
        config = """import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { visualizer } from 'rollup-plugin-visualizer'
import viteCompression from 'vite-plugin-compression'
import path from 'path'

export default defineConfig({
  plugins: [
    react(),
    viteCompression({
      algorithm: 'gzip',
      threshold: 10240,
    }),
    visualizer({
      filename: './dist/stats.html',
      gzipSize: true,
      brotliSize: true,
    }),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    target: 'es2015',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true,
      },
    },
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
        },
      },
    },
    cssCodeSplit: true,
    sourcemap: false,
    chunkSizeWarningLimit: 500,
  },
  server: {
    port: 3000,
    host: true,
  },
})
"""
        (self.project_path / "vite.config.ts").write_text(config)
        
    def generate_tsconfig(self):
        """Generate tsconfig.json"""
        config = {
            "compilerOptions": {
                "target": "ES2020",
                "useDefineForClassFields": True,
                "lib": ["ES2020", "DOM", "DOM.Iterable"],
                "module": "ESNext",
                "skipLibCheck": True,
                "moduleResolution": "bundler",
                "allowImportingTsExtensions": True,
                "resolveJsonModule": True,
                "isolatedModules": True,
                "noEmit": True,
                "jsx": "react-jsx",
                "strict": True,
                "noUnusedLocals": True,
                "noUnusedParameters": True,
                "noFallthroughCasesInSwitch": True,
                "baseUrl": ".",
                "paths": {
                    "@/*": ["./src/*"]
                }
            },
            "include": ["src"],
            "references": [{"path": "./tsconfig.node.json"}]
        }
        (self.project_path / "tsconfig.json").write_text(json.dumps(config, indent=2))
        
    def generate_tsconfig_node(self):
        """Generate tsconfig.node.json"""
        config = {
            "compilerOptions": {
                "composite": True,
                "skipLibCheck": True,
                "module": "ESNext",
                "moduleResolution": "bundler",
                "allowSyntheticDefaultImports": True,
                "strict": True
            },
            "include": ["vite.config.ts"]
        }
        (self.project_path / "tsconfig.node.json").write_text(json.dumps(config, indent=2))
        
    def generate_index_html(self):
        """Generate index.html with preload"""
        html = """<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Professional web development and digital services" />
    
    <!-- Preload critical fonts -->
    <link rel="preload" href="/node_modules/@fontsource/goldman/files/goldman-latin-400-normal.woff2" as="font" type="font/woff2" crossorigin />
    
    <title>Minimalist Site</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
"""
        (self.project_path / "index.html").write_text(html)
        
    def generate_fonts_css(self):
        """Generate optimized CSS with system fonts first"""
        css = """/* System fonts first for instant render */
:root {
  --font-system: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-system);
  color: #000;
  background: #fff;
  line-height: 1.8;
  font-weight: 300;
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-system);
  font-weight: 500;
  line-height: 1.3;
  letter-spacing: -0.02em;
}

.btn {
  display: inline-flex;
  padding: 0.75rem 2rem;
  border: 1px solid #000;
  background: transparent;
  color: #000;
  cursor: pointer;
  transition: opacity 0.2s;
  text-decoration: none;
  font-size: 0.875rem;
}

.btn:hover {
  opacity: 0.6;
}

.btn-primary {
  background: #000;
  color: #fff;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1.5rem;
}

@media (min-width: 768px) {
  .container {
    padding: 0 2rem;
  }
}
"""
        (self.project_path / "src/styles/fonts.css").write_text(css)
        
    def generate_site_config(self):
        """Generate site config"""
        config = """export const siteConfig = {
  name: "YourCompany",
  tagline: "Professional Web Solutions",
  description: "Modern web development and digital services",
  contact: {
    email: "hello@yourcompany.com",
    phone: "+1 (555) 123-4567",
  },
  social: {
    github: "https://github.com/yourcompany",
    linkedin: "https://linkedin.com/company/yourcompany",
  },
}
"""
        (self.project_path / "src/config/site.ts").write_text(config)
        
    def generate_header(self):
        """Generate Header component"""
        component = """import { siteConfig } from '@/config/site'

export const Header = () => {
  return (
    <header style={{ borderBottom: '1px solid #e0e0e0', padding: '1.5rem 0' }}>
      <div className="container">
        <nav style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ fontFamily: 'var(--font-goldman)', fontSize: '1.125rem' }}>
            {siteConfig.name}
          </div>
          <div style={{ display: 'flex', gap: '3rem' }}>
            <a href="#services" style={{ color: '#000', textDecoration: 'none', fontSize: '0.875rem' }}>Services</a>
            <a href="#contact" style={{ color: '#000', textDecoration: 'none', fontSize: '0.875rem' }}>Contact</a>
          </div>
        </nav>
      </div>
    </header>
  )
}
"""
        (self.project_path / "src/components/layout/Header.tsx").write_text(component)
        
    def generate_hero(self):
        """Generate Hero component"""
        component = """import { siteConfig } from '@/config/site'

export const Hero = () => {
  return (
    <section style={{ minHeight: '70vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div className="container" style={{ textAlign: 'center' }}>
        <h1 style={{ 
          fontSize: 'clamp(2.5rem, 8vw, 4.5rem)', 
          fontFamily: 'var(--font-goldman)',
          marginBottom: '2rem',
          fontWeight: 400
        }}>
          {siteConfig.tagline}
        </h1>
        <p style={{ fontSize: '1.125rem', color: '#666', marginBottom: '3rem', maxWidth: '40rem', margin: '0 auto 3rem' }}>
          {siteConfig.description}
        </p>
        <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' }}>
          <a href="#services" className="btn btn-primary">View Work</a>
          <a href="#contact" className="btn">Get in Touch</a>
        </div>
      </div>
    </section>
  )
}
"""
        (self.project_path / "src/components/sections/Hero.tsx").write_text(component)
        
    def generate_contact(self):
        """Generate Contact component"""
        component = """import { siteConfig } from '@/config/site'

export const Contact = () => {
  return (
    <section id="contact" style={{ padding: '6rem 0', borderTop: '1px solid #e0e0e0' }}>
      <div className="container">
        <h2 style={{ 
          fontSize: '3rem', 
          fontFamily: 'var(--font-goldman)',
          marginBottom: '3rem',
          fontWeight: 400
        }}>
          Contact
        </h2>
        <div style={{ maxWidth: '60rem', display: 'grid', gap: '4rem', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))' }}>
          <div>
            <h3 style={{ fontSize: '0.875rem', color: '#666', marginBottom: '0.5rem' }}>Email</h3>
            <a href={`mailto:${siteConfig.contact.email}`} style={{ fontSize: '1.125rem', color: '#000' }}>
              {siteConfig.contact.email}
            </a>
          </div>
          <div>
            <h3 style={{ fontSize: '0.875rem', color: '#666', marginBottom: '0.5rem' }}>Phone</h3>
            <a href={`tel:${siteConfig.contact.phone}`} style={{ fontSize: '1.125rem', color: '#000' }}>
              {siteConfig.contact.phone}
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}
"""
        (self.project_path / "src/components/sections/Contact.tsx").write_text(component)
        
    def generate_app(self):
        """Generate App.tsx"""
        app = """import { Header } from './components/layout/Header'
import { Hero } from './components/sections/Hero'
import { Contact } from './components/sections/Contact'
import './styles/fonts.css'

function App() {
  return (
    <>
      <Header />
      <main>
        <Hero />
        <Contact />
      </main>
    </>
  )
}

export default App
"""
        (self.project_path / "src/App.tsx").write_text(app)
        
    def generate_main(self):
        """Generate main.tsx"""
        main = """import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
"""
        (self.project_path / "src/main.tsx").write_text(main)
        
    def generate_vite_env(self):
        """Generate vite-env.d.ts"""
        content = '/// <reference types="vite/client" />\n'
        (self.project_path / "src/vite-env.d.ts").write_text(content)
        
    def install_deps(self):
        """Install npm dependencies"""
        print("\n📦 Installing dependencies...")
        subprocess.run(["npm", "install"], cwd=self.project_path, check=True)
        
    def build(self):
        """Run complete build"""
        print("\n🚀 CH405 VITE BOOTSTRAP\n" + "=" * 60)
        
        self.create_structure()
        self.generate_package_json()
        self.generate_vite_config()
        self.generate_tsconfig()
        self.generate_tsconfig_node()
        self.generate_index_html()
        self.generate_fonts_css()
        self.generate_site_config()
        self.generate_header()
        self.generate_hero()
        self.generate_contact()
        self.generate_app()
        self.generate_main()
        self.generate_vite_env()
        self.generate_robots_txt()
        self.install_deps()
        
        print("\n" + "=" * 60)
        print("✅ PROJECT CREATED")
        print("=" * 60)
        print(f"\n📁 Location: {self.project_path.absolute()}")
        print("\n🚀 Run:")
        print(f"   cd {self.project_name}")
        print("   npm run dev")
        print("\n")


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 vite_bootstrap_fixed.py <project-name>")
        sys.exit(1)
        
    project_name = sys.argv[1]
    bootstrap = ViteBootstrap(project_name)
    bootstrap.build()
