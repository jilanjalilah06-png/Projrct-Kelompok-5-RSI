@echo off
echo [AgriConnect] Memulai backup database dari Docker...
docker exec -i agriconnect_db mysqldump -u agriconnect_user -psecret --no-tablespaces agriconnect > be/backup_agriconnect.sql
echo [AgriConnect] Backup selesai! File 'be/backup_agriconnect.sql' telah diperbarui.
echo.
pause
