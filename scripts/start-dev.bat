@echo off
echo 🚀 DevFeed Phase 1을 시작합니다...
echo (PostgreSQL + Redis + Spring Boot)

REM Docker 실행 확인
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker가 설치되어 있지 않거나 실행되지 않습니다.
    pause
    exit /b 1
)

REM 기존 컨테이너 정리
echo 🧹 기존 컨테이너 정리 중...
docker-compose down

REM JAR 파일 존재 확인 및 빌드
if not exist "build\libs\devfeed-*.jar" (
    echo 📦 JAR 파일이 없습니다. 빌드를 시작합니다...
    call gradlew.bat clean build -x test
    if errorlevel 1 (
        echo ❌ 빌드 실패했습니다.
        echo 💡 수동으로 빌드해보세요: gradlew.bat build
        pause
        exit /b 1
    )
    echo ✅ 빌드 완료!
) else (
    echo ✅ JAR 파일이 이미 존재합니다.
)

REM 데이터베이스와 Redis 먼저 시작
echo 🐘 데이터베이스와 Redis를 시작 중...
docker-compose up -d postgres redis

REM 데이터베이스 준비 대기
echo ⏳ 데이터베이스 준비 중... (20초 대기)
timeout /t 20 /nobreak >nul

REM DevFeed 백엔드 빌드 및 시작
echo 🔨 DevFeed 백엔드 Docker 이미지 빌드 중...
docker-compose build devfeed-backend

echo 🚀 DevFeed 백엔드를 시작 중...
docker-compose up -d devfeed-backend

REM 백엔드 준비 대기
echo ⏳ 백엔드 준비 중... (30초 대기)
timeout /t 30 /nobreak >nul

REM 상태 확인
echo 📊 Phase 1 시스템 상태:
docker-compose ps

echo.
echo ✅ DevFeed Phase 1이 시작되었습니다!
echo.
echo 🔗 접속 URL:
echo   - DevFeed API: http://localhost:8080
echo   - Health Check: http://localhost:8080/actuator/health
echo   - PostgreSQL: localhost:5432 (developer/dev123!)
echo   - Redis: localhost:6379
echo.
echo 📋 Phase 1 기능:
echo   - RSS 피드 수집 (5분마다)
echo   - 기사 저장 및 조회 API
echo   - 기본 캐싱 (Redis)
echo.
echo 💡 API 테스트:
echo   GET  http://localhost:8080/api/v1/articles
echo   POST http://localhost:8080/api/v1/articles/collect
echo.
echo 🐛 문제 발생 시:
echo   - 로그 확인: docker-compose logs devfeed-backend
echo   - 재시작: scripts\stop-dev.bat 후 다시 실행
echo.
pause