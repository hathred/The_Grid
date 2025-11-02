@echo off
setlocal enabledelayedexpansion

echo Generating image gallery from images folder...

set "output=index.html"
set "imagedir=images"

if not exist "%imagedir%" (
    echo Error: images folder not found!
    pause
    exit /b 1
)

rem Create temporary JavaScript file
set "tempjs=temp_categories.js"
echo const categories = { > "%tempjs%"

rem Scan images folder for categories
set "currentCat="
set "firstCat=1"

for /d %%c in ("%imagedir%\*") do (
    set "catname=%%~nc"
    
    rem Start category
    if "!firstCat!"=="1" (
        set "firstCat=0"
    ) else (
        echo , >> "%tempjs%"
    )
    echo             '!catname!': [ >> "%tempjs%"
    
    rem Scan files in this category
    set "firstFile=1"
    for %%f in ("%%c\*") do (
        set "filename=%%~nxf"
        set "ext=%%~xf"
        
        rem Determine file type
        set "type=image"
        if /i "!ext!"==".pdf" set "type=pdf"
        if /i "!ext!"==".doc" set "type=doc"
        if /i "!ext!"==".docx" set "type=doc"
        
        rem Escape single quotes in filename
        set "safefile=!filename:'=\'!"
        
        rem Add comma if not first file
        if "!firstFile!"=="1" (
            set "firstFile=0"
        ) else (
            echo , >> "%tempjs%"
        )
        
        rem Write file entry (without trailing comma)
        <nul set /p "={file: '!safefile!', type: '!type!'}" >> "%tempjs%"
    )
    
    rem Close category array
    echo. >> "%tempjs%"
    echo             ] >> "%tempjs%"
)

rem Close categories object
echo         }; >> "%tempjs%"

rem Build HTML file
(
echo ^<!DOCTYPE html^>
echo ^<html lang="en"^>
echo ^<head^>
echo     ^<meta charset="UTF-8"^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
echo     ^<title^>Image Gallery^</title^>
echo     ^<style^>
echo         * { margin: 0; padding: 0; box-sizing: border-box; }
echo         body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a1a; color: #e0e0e0; padding: 20px; }
echo         .container { max-width: 1400px; margin: 0 auto; }
echo         h1 { text-align: center; margin-bottom: 40px; color: #fff; font-size: 2.5em; }
echo         .category { margin-bottom: 50px; background: #2a2a2a; border-radius: 12px; padding: 25px; box-shadow: 0 4px 6px rgba(0,0,0,0.3^); }
echo         .category-title { font-size: 1.8em; margin-bottom: 20px; color: #4a9eff; border-bottom: 2px solid #4a9eff; padding-bottom: 10px; }
echo         .image-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr^)^); gap: 20px; }
echo         .image-item { background: #333; border-radius: 8px; overflow: hidden; transition: transform 0.3s ease, box-shadow 0.3s ease; }
echo         .image-item:hover { transform: translateY(-5px^); box-shadow: 0 8px 16px rgba(74, 158, 255, 0.3^); }
echo         .image-item a { display: block; text-decoration: none; }
echo         .thumbnail-container { width: 100%%; height: 250px; background: #222; display: flex; align-items: center; justify-content: center; overflow: hidden; }
echo         .thumbnail-container img { max-width: 100%%; max-height: 100%%; object-fit: contain; }
echo         .image-name { padding: 15px; color: #e0e0e0; font-size: 0.9em; word-break: break-word; background: #3a3a3a; }
echo         .image-name:hover { color: #4a9eff; }
echo         .doc-placeholder { color: #888; padding: 20px; text-align: center; }
echo         .nav-buttons { display: flex; gap: 10px; margin-bottom: 30px; flex-wrap: wrap; }
echo         .nav-button { background: #3a3a3a; color: #4a9eff; padding: 10px 20px; border-radius: 6px; cursor: pointer; border: 2px solid #4a9eff; font-size: 1em; transition: all 0.3s ease; }
echo         .nav-button:hover { background: #4a9eff; color: #fff; }
echo         .nav-button.active { background: #4a9eff; color: #fff; }
echo     ^</style^>
echo ^</head^>
echo ^<body^>
echo     ^<div class="container"^>
echo         ^<h1^>Image Gallery^</h1^>
echo         ^<div class="nav-buttons" id="navButtons"^>^</div^>
echo         ^<div id="content"^>^</div^>
echo     ^</div^>
echo     ^<script^>
) > "%output%"

rem Append categories
type "%tempjs%" >> "%output%"

rem Continue JavaScript
(
echo.
echo         console.log^('Categories loaded:', categories^);
echo.
echo         let currentCategory = 'all';
echo.
echo         function createNavButtons^(^) {
echo             const nav = document.getElementById^('navButtons'^);
echo             const allBtn = document.createElement^('button'^);
echo             allBtn.className = 'nav-button active';
echo             allBtn.textContent = 'All Categories';
echo             allBtn.onclick = function^(^) { showCategory^('all'^); };
echo             nav.appendChild^(allBtn^);
echo             Object.keys^(categories^).forEach^(function^(cat^) {
echo                 const btn = document.createElement^('button'^);
echo                 btn.className = 'nav-button';
echo                 btn.textContent = cat;
echo                 btn.onclick = function^(^) { showCategory^(cat^); };
echo                 nav.appendChild^(btn^);
echo             }^);
echo         }
echo.
echo         function showCategory^(cat^) {
echo             currentCategory = cat;
echo             document.querySelectorAll^('.nav-button'^).forEach^(function^(btn^) {
echo                 btn.classList.remove^('active'^);
echo             }^);
echo             if ^(event ^&^& event.target^) {
echo                 event.target.classList.add^('active'^);
echo             } else {
echo                 document.querySelector^('.nav-button'^).classList.add^('active'^);
echo             }
echo             const content = document.getElementById^('content'^);
echo             content.innerHTML = '';
echo             if ^(cat === 'all'^) {
echo                 Object.keys^(categories^).forEach^(function^(category^) {
echo                     content.appendChild^(createCategorySection^(category, categories[category]^)^);
echo                 }^);
echo             } else {
echo                 content.appendChild^(createCategorySection^(cat, categories[cat]^)^);
echo             }
echo         }
echo.
echo         function createCategorySection^(category, files^) {
echo             const section = document.createElement^('div'^);
echo             section.className = 'category';
echo             const title = document.createElement^('h2'^);
echo             title.className = 'category-title';
echo             title.textContent = category;
echo             section.appendChild^(title^);
echo             const grid = document.createElement^('div'^);
echo             grid.className = 'image-grid';
echo             files.forEach^(function^(item^) {
echo                 const itemDiv = document.createElement^('div'^);
echo                 itemDiv.className = 'image-item';
echo                 const link = document.createElement^('a'^);
echo                 const path = 'images/' + category + '/' + item.file;
echo                 link.href = path;
echo                 link.target = '_blank';
echo                 const thumbContainer = document.createElement^('div'^);
echo                 thumbContainer.className = 'thumbnail-container';
echo                 if ^(item.type === 'image'^) {
echo                     const img = document.createElement^('img'^);
echo                     img.src = path;
echo                     img.alt = item.file;
echo                     thumbContainer.appendChild^(img^);
echo                 } else if ^(item.type === 'pdf'^) {
echo                     const placeholder = document.createElement^('div'^);
echo                     placeholder.className = 'doc-placeholder';
echo                     placeholder.textContent = '📄 PDF Document';
echo                     thumbContainer.appendChild^(placeholder^);
echo                 } else if ^(item.type === 'doc'^) {
echo                     const placeholder = document.createElement^('div'^);
echo                     placeholder.className = 'doc-placeholder';
echo                     placeholder.textContent = '📝 Word Document';
echo                     thumbContainer.appendChild^(placeholder^);
echo                 }
echo                 const name = document.createElement^('div'^);
echo                 name.className = 'image-name';
echo                 name.textContent = item.file;
echo                 link.appendChild^(thumbContainer^);
echo                 link.appendChild^(name^);
echo                 itemDiv.appendChild^(link^);
echo                 grid.appendChild^(itemDiv^);
echo             }^);
echo             section.appendChild^(grid^);
echo             return section;
echo         }
echo.
echo         createNavButtons^(^);
echo         showCategory^('all'^);
echo     ^</script^>
echo ^</body^>
echo ^</html^>
) >> "%output%"

rem Clean up
del "%tempjs%"

echo.
echo Gallery generated successfully: %output%
echo Found categories:
for /d %%c in ("%imagedir%\*") do (
    echo   - %%~nc
)
echo.
echo Open index.html in your browser to view.
echo.
pause