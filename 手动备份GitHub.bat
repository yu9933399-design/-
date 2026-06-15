@echo off
cd /d "%~dp0"

echo 正在提交并推送到 GitHub...
git add .
git commit -m "手动备份 %date% %time%"
git push origin main

echo.
echo 备份完成！
pause