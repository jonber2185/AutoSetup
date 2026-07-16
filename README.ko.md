# Windows Auto Setup

> **개발용 SDK**, **일반 프로그램**, **개인 환경 설정**을 한 번의 실행으로 조용히(silent) 세팅해주는 PowerShell 기반 Windows 자동 설치 스크립트입니다.

[English](README.md)

---

## Features

- **원클릭 설치** — `install.bat` 한 번 실행으로 나머지는 전부 자동 처리
- **SDK 설치** — 개발용 SDK(JDK, Node.js, Python, Git, Flutter)를 고정 경로에 설치하고 환경변수까지 자동 등록
- **프로그램 설치** — 로컬 설치파일 + `winget` 기반 프로그램 목록을 함께 설치
- **개인 환경 설정** — 라이선스 키 복사, 개인 이미지 복원, 커스텀 아이콘/배경화면 적용
- **완전 무인(Silent) 설치** — 모든 설치 단계가 팝업/프롬프트 없이 자동으로 진행
- **로그 기록** — 모든 동작이 타임스탬프와 함께 `install_log.txt`에 기록됨

## Tech Stack

| Layer | Technology |
|---|---|
| Script | PowerShell 5.1+ |
| Entry Point | Windows Batch (`.bat`) |
| Package Manager | [winget](https://learn.microsoft.com/windows/package-manager/winget/) |
| Privilege Handling | `Start-Process -Verb RunAs` 를 이용한 UAC 자동 상승 |
| Archive Handling | Windows 10/11 내장 `tar` |

## Project Structure

```
.
├── scripts/
│   ├── install.bat          # 실행 진입점 (이걸 실행하면 됨)
│   ├── common.ps1           # 공통 함수 (로그, 폴더 처리, 환경변수 등록, winget 설치)
│   ├── install_all.ps1      # 오케스트레이터 - SDK → 프로그램 → 추가설정 순서로 실행
│   ├── install_sdk.ps1      # 개발용 SDK 설치 (JDK, Node.js, Python, Flutter, Git 등)
│   ├── install_program.ps1  # 로컬 설치파일 + winget 패키지 설치
│   └── install_addition.ps1 # 개인 설정: 레지스트리 조정, keys/images 이동, 아이콘, 배경화면
├── installer/
│   ├── SDK/                 # SDK 설치파일 위치 (jdk, node, python, git, flutter zip 등)
│   └── program/             # 일반 프로그램 설치파일 위치 (Chrome, Office, VMware 등)
├── keys/                    # 개인 라이선스 키 / 설정 파일 → Documents 로 복사됨
└── images/                  # 개인 이미지, 카테고리별 하위 폴더 → 각각 Pictures 로 복사됨
```

`installer/`, `keys/`, `images/`는 모두 `scripts/`와 같은 레벨, 즉 `scripts/`의 상위 폴더(`$Root`)에 위치합니다.

## How to Run

1. `installer/SDK/`에 SDK 설치파일을, `installer/program/`에 일반 프로그램 설치파일을 넣습니다.
2. (선택) `keys/`에 개인 파일을, `images/`에 이미지 하위 폴더를 넣습니다.
3. `install.bat`을 실행합니다.

```
install.bat
```

`install.bat`은 `-ExecutionPolicy Bypass` 옵션으로 `scripts\install_all.ps1`을 실행하는 역할만 합니다. 관리자 권한이 아니라면 자동으로 관리자 권한으로 재실행됩니다.

## Usage

### 설치 흐름

| Step | Script | Description |
|---|---|---|
| 1 | `install_sdk.ps1` | `installer/SDK/`를 스캔해 조건에 맞는 SDK를 `C:\SDK\...`에 조용히 설치하고, `JAVA_HOME`과 PATH를 등록 |
| 2 | `install_program.ps1` | `installer/program/`을 스캔해 조건에 맞는 프로그램을 조용히 설치한 뒤, 지정된 프로그램 목록을 `winget`으로 추가 설치 |
| 3 | `install_addition.ps1` | 레지스트리 조정, `keys/` → Documents 복사, `images/*` 하위 폴더 → Pictures 복사, 아이콘/배경화면 설정 |

### 프로그램 추가/삭제 방법

| 대상 | 방법 |
|---|---|
| 설치파일 기반 항목 (SDK/program) | `install_sdk.ps1` / `install_program.ps1`의 `$config` 배열에서 항목(`Pattern`, `TargetDir`, `Action`) 추가/삭제 |
| winget 기반 항목 | `install_program.ps1` 하단에 `Install-Program '<winget 패키지 ID>' '<선택적 silent 옵션>'` 한 줄 추가/삭제 |
| 새로운 설치 단계 | `scripts/` 밑에 새 `.ps1` 파일을 만들고 `install_all.ps1`에서 dot-source로 불러오기 |

### `keys/`, `images/` 동작 방식

| 폴더 | 동작 |
|---|---|
| `keys/` | 폴더 통째로 **Documents** 로 복사됨 (`Documents\keys\...`) |
| `images/` | `images/` 바로 아래의 **하위 폴더들만** 각각 개별적으로 **Pictures** 로 복사됨 (예: `images/wallpaper/` → `Pictures/wallpaper/`). `images/` 바로 안의 낱개 파일은 무시됨 |

아이콘과 배경화면은 `Documents\keys\icon\icon_file1.ico`, `Pictures\wallpaper\1.png` 같은 고정 경로를 참조해서 적용됩니다 — 이 상대경로/파일명을 그대로 맞추거나, `install_addition.ps1` 안의 경로를 자신의 파일에 맞게 수정하세요.

### SDK 및 환경변수

`install_sdk.ps1`에서 SDK를 추가/삭제하거나 버전/경로를 변경한다면 아래도 함께 수정해야 합니다.

| 변수 | 용도 |
|---|---|
| `$envVars` | 시스템 환경변수 (예: `JAVA_HOME`) |
| `$pathsToAdd` | 시스템 `PATH` 맨 앞에 추가될 폴더 목록 |

두 값 모두 `common.ps1`의 `Set-SystemEnvironment` 함수로 전달되어 레지스트리 등록, 현재 세션 반영, PATH 중복 제거까지 함께 처리됩니다.

## Note
- **모든 설치 단계는 무인(silent) 설치를 지향합니다.** 새 프로그램을 추가할 때는 인터랙티브하게 실행하지 말고, 실제 silent 설치 옵션(`/S`, `/silent`, `/quiet`, `--silent`, winget의 `--accept-source-agreements --accept-package-agreements` 등)을 찾아서 사용하세요.
- 설치를 두 번 실행하면 각 silent 설치 프로그램이 다시 실행됩니다. PATH 항목은 중복 제거되지만, 설치된 프로그램 자체는 그렇지 않습니다.
- 이 도구는 **신뢰할 수 있는 단일 PC에서의 개인 환경 자동화 용도**로 제작되었습니다.