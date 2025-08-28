@echo off
REM scripts\stop-dev.bat - Windows 개발환경 중지 스크립트

echo 🛑 DevFeed 개발환경을 중지합니다...

REM 컨테이너 중지
docker-compose down

REM 볼륨 삭제 여부 확인
echo.
set /p "answer=데이터 볼륨도 삭제하시겠습니까? (데이터가 모두 삭제됩니다!) [y/N]: "
if /i "%answer%"=="y" (
    echo 🗑️  데이터 볼륨을 삭제 중...
    docker-compose down -v
    docker system prune -f
)

echo ✅ 개발환경이 중지되었습니다.
pause