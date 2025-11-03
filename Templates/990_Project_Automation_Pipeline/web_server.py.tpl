:: WARNING: This is a generated template from web_server.py (Source Folder: 990_Project_Automation_Pipeline)
:: Check the token replacements (__XXX__) for correctness.

import os
import json
import gzip
import base64
import re
from pathlib import Path
from flask import Flask, render_template_string, abort
import markdown
from markdown.extensions.fenced_code import FencedCodeExtension
from markdown.extensions.tables import TableExtension

app = Flask(__name__)
DML_ROOT = Path(r"__ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize\output")
# Global MD renderer
md = markdown.Markdown(extensions=[FencedCodeExtension(), TableExtension()])

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
  <title>DML Web Dashboard</title>
  <style>
    body { font-family: Consolas, monospace; background: #0d1117; color: #c9d1d9; padding: 20px; }
    h1 { color: #58a6ff; }
    .file-list { margin: 20px 0; }
    .file { padding: 10px; background: #161b22; margin: 5px 0; border-radius: 6px; cursor: pointer; }
    .file:hover { background: #21262d; }
    .meta { color: #8b949e; font-size: 0.9em; }
    pre { background: #161b22; padding: 15px; border-radius: 6px; overflow-x: auto; }
  </style>
</head>
<body>
  <h1>DML Web Dashboard</h1>
  <p><strong>Root:</strong> {{ root }}</p>
  <div class="file-list">
    {% for file in files %}
      <div class="file" onclick="location.href='{{ file.rel }}'">
        {{ file.name }} <span class="meta">({{ file.size }} KB)</span>
      </div>
    {% else %}
      <p>No DML files found.</p>
    {% endfor %}
  </div>
  <script>
    setTimeout(() => location.reload(), 30000);
  </script>
</body>
</html>
"""

def decode_dml_recursive(raw_content, depth=0, max_depth=10):
    """Return (html, is_dml) for nested content"""
    if depth > max_depth:
        return "<em style='color:#8b949e;'>[Max depth]</em>", False

    try:
        data = json.loads(raw_content)
    except:
        return raw_content, False

    if not isinstance(data, dict) or 'content' not in data:
        return json.dumps(data, indent=2, ensure_ascii=False), False

    content = data['content']
    source = data.get('source', '')

    # --- NESTED DML ---
    try:
        if isinstance(content, str) and len(content) > 100:
            decoded = gzip.decompress(base64.b64decode(content)).decode('utf-8')
            inner_html, is_dml = decode_dml_recursive(decoded, depth + 1, max_depth)
            if is_dml or inner_html.strip().startswith(('<', '{', '[')):
              return f"""
              <details style='margin:8px 0; padding:8px; border-left:3px solid #58a6ff;'>
                <summary style='color:#58a6ff; cursor:pointer; font-weight:bold;'>
                  📄 Nested: {source or 'DML'}
                </summary>
                <div style='margin-top:8px; padding-left:16px;'>
                  {inner_html}
                </div>
              </details>
              """, True
    except:
        pass

    return json.dumps(data, indent=2, ensure_ascii=False), False

def render_dml_content(data, depth=0, max_depth=10):
    if depth > max_depth:
        return "<em style='color:#8b949e;'>[Max depth]</em>"

    if not isinstance(data, dict):
        return str(data)

    html_parts = []

    for key, value in data.items():
        if key == 'content' and isinstance(value, str):
            # NESTED DML
            try:
              if len(value) > 100 and value.strip().startswith('H4sI'):
                  decoded = gzip.decompress(base64.b64decode(value)).decode('utf-8')
                  inner = render_dml_content(json.loads(decoded), depth + 1, max_depth)
                  html_parts.append(f"""
                  <details>
                    <summary>Nested DML</summary>
                    <div style='margin-top:8px; padding-left:8px;'>
                      {inner}
                    </div>
                  </details>
                  """)
                  continue
            except:
              pass

            # MARKDOWN
            rendered = md.reset().convert(value)
            html_parts.append(f"<div class='md-content'>{rendered}</div>")

        elif isinstance(value, (dict, list)):
            inner = render_dml_content(value, depth + 1, max_depth)
            label = f"<strong>{key}:</strong>" if depth == 0 else ""
            html_parts.append(f"<div style='margin:1em 0;'>{label} {inner}</div>")
        else:
            html_parts.append(f"<div style='margin:0.5em 0;'><strong>{key}:</strong> {value}</div>")

    return "".join(html_parts)
    
def highlight_code(text, ext):
    try:
        from pygments import highlight
        from pygments.lexers import get_lexer_by_name
        from pygments.formatters import HtmlFormatter
        lang = 'yaml' if ext in {'.yaml', '.yml'} else 'json' if ext == '.json' else 'text'
        lexer = get_lexer_by_name(lang, stripall=True)
        formatter = HtmlFormatter(style='github-dark', linenos=True, cssclass='code-block')
        return highlight(text, lexer, formatter)
    except:
        return f"<pre class='code-block'><code>{text}</code></pre>"

def add_copy_buttons(html):
    return html.replace('<pre class="code-block">', 
                       '<div class="code-block"><button class="copy-btn">Copy</button><pre>')

def get_pygments_css():
    try:
        from pygments.formatters import HtmlFormatter
        return HtmlFormatter(style='github-dark').get_style_defs('.code-block')
    except:
        return ""

@app.route("/")
def index():
    files = []
    for dml_file in DML_ROOT.rglob("*.dml.b64"):
        rel = dml_file.relative_to(DML_ROOT)
        rel_str = rel.as_posix()
        size_kb = dml_file.stat().st_size / 1024
        files.append({
            "name": rel_str,
            "rel": f"/view/{rel_str}",
            "size": f"{size_kb:.1f}"
        })
    
    files.sort(key=lambda x: x["name"].lower())
    
    return render_template_string(HTML_TEMPLATE, root=str(DML_ROOT), files=files)

@app.route("/view/<path:rel_path>")
def view_file(rel_path):
    file_path = (DML_ROOT / rel_path).resolve()
    if not file_path.is_relative_to(DML_ROOT) or not file_path.exists():
        abort(404)
    
    try:
        dml = json.load(open(file_path, 'r', encoding='utf-8'))
        source = dml.get('source', Path(rel_path).stem.replace('.dml.b64', ''))
        ext = Path(source).suffix.lower()

        # --- DECOMPRESS DATA ---
        raw = gzip.decompress(base64.b64decode(dml['data'])).decode('utf-8')
        data = json.loads(raw)

        # --- RENDER ---
        if isinstance(data, dict) and 'content' in data:
            content = data['content']
            if isinstance(content, str):
                # Try nested DML
                try:
                    if len(content) > 100 and content.strip().startswith('H4sI'):
                        decoded = gzip.decompress(base64.b64decode(content)).decode('utf-8')
                        nested_data = json.loads(decoded)
                        content_html = render_dml_content(nested_data)
                    else:
                        # Render as MD
                        if any(content.strip().startswith(prefix) for prefix in ['# ', '## ', '- ', '* ', '1. ', '---']):
                            content_html = md.reset().convert(content)
                        else:
                            content_html = highlight_code(content, ext)
                except:
                    content_html = highlight_code(content, ext)
            else:
                content_html = render_dml_content(data)
        else:
            content_html = render_dml_content(data)

        content_html = add_copy_buttons(content_html)
        pygments_css = get_pygments_css()

        return f"""
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>{source}</title>
          <style>
            {pygments_css}
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
                    background: #0d1117; color: #c9d1d9; padding: 32px; margin: 0; line-height: 1.6; }}
            .container {{ max-width: 960px; margin: auto; }}
            h1 {{ color: #58a6ff; margin: 0 0 0.5em; font-size: 1.9em; font-weight: 600; }}
            .meta {{ color: #8b949e; font-size: 0.9em; margin-bottom: 2em; }}
            .content {{ background:#161b22; padding: 36px; border-radius: 14px; box-shadow: 0 8px 20px rgba(0,0,0,0.5); }}
            .md-content {{ margin: 2em 0; }}
            .md-content h2, .md-content h3 {{ color: #58a6ff; margin: 1.6em 0 0.9em; font-weight: 600; }}
            .md-content p {{ margin: 1.1em 0; }}
            .md-content ul, .md-content ol {{ padding-left: 1.8em; margin: 1.3em 0; }}
            .md-content li {{ margin: 0.6em 0; }}
            .md-content code {{ background: #21262d; padding: 3px 7px; border-radius: 4px; font-size: 0.88em; }}
            .code-block {{ position: relative; background: #0d1117; padding: 22px; border-radius: 10px; margin: 2em 0; overflow: auto; border: 1px solid #30363d; }}
            .code-block .lineno {{ color: #6e7681; padding-right: 16px; }}
            .copy-btn {{ position: absolute; top: 14px; right: 14px; background: #21262d; color: #c9d1d9; border: none; border-radius: 6px; padding: 8px 12px; font-size: 0.8em; cursor: pointer; }}
            .copy-btn:hover {{ background: #30363d; }}
            .back-link {{ display: inline-block; margin-top: 2.5em; padding: 14px 20px; background: #21262d; border-radius: 8px; font-size: 0.9em; }}
            a {{ color: #58a6ff; text-decoration: none; }} a:hover {{ text-decoration: underline; }}
          </style>
        </head>
        <body>
          <div class="container">
            <h1>{source}</h1>
            <p class="meta">Path: <code>{file_path}</code></p>
            <div class="content">
              {content_html}
            </div>
            <a href="/" class="back-link">Back to Dashboard</a>
          </div>
          <script>
            document.querySelectorAll('.copy-btn').forEach(btn => {{
              btn.onclick = () => {{
                const code = btn.parentElement.querySelector('pre').innerText;
                navigator.clipboard.writeText(code);
                const orig = btn.innerText;
                btn.innerText = 'Copied!';
                setTimeout(() => btn.innerText = orig, 2000);
              }};
            }});
          </script>
        </body>
        </html>
        """
    except Exception as e:
        return f"<pre style='color:red; background:#161b22; padding:20px;'>ERROR: {e}</pre>"

if __name__ == "__main__":
    print("DML Web Dashboard → http://localhost:8000")
    app.run(host="localhost", port=8000, debug=False)