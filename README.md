# Docker 프로젝트 마이그레이션 도구

Docker 프로젝트를 빠르게 마이그레이션할 수 있는 대화형 CLI 도구입니다.

## 🛠 주요 기능

- **대화형 설정**: 사용자 친화적인 대화형 설정 방식
- **환경 종속성 자동 검사**: 필요한 종속성을 자동으로 확인
- **설정 파일 지원**: 손쉽게 기본 설정 관리
- **오류 처리 및 복구**: 안정적인 작업 수행 보장
- **자동 백업**: 데이터 안전성을 보장하는 백업 기능

## 🚀 사용 방법

아래 명령어를 터미널에 입력하세요:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lunarhash/dockermigration/refs/heads/main/install.sh)

📂 설정 파일

설정 파일은 다음 위치에 저장됩니다: ~/.docker_install_config
기본 설정을 변경하려면 이 파일을 직접 편집하세요.

⚠️ 주의 사항

	•	소스 서버와 대상 서버에 Docker와 docker-compose가 설치되어 있어야 합니다.
	•	마이그레이션 전에 중요한 데이터를 백업하는 것이 좋습니다.
	•	서버 간 SSH 연결이 가능한지 확인하세요.
