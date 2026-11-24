# Unity MCP 설정 및 Claude 연동 정리

Unity 에디터에 **MCP for Unity**를 설치하고 Claude와 연결해, 채팅으로 Unity를 조작하기까지의 과정을 정리한 문서입니다.

- 작성일: 2026-11-24
- 확인한 환경: Unity 6000.0.85f2, MCP for Unity 10.3.0, Claude Desktop
- 연습에 쓴 프로젝트: `Dodge` (빌트인 렌더 파이프라인)

---

## 1. 준비물

| 항목 | 요구 사항 |
|---|---|
| Unity | 2021.3 LTS 이상 |
| Python | 3.10 이상 |
| uv | Python 패키지 관리자 (없으면 설치 후 나오는 설정 마법사가 안내) |
| MCP 클라이언트 | Claude Desktop 등 (이 문서는 Claude Desktop 기준) |
| Claude 데스크톱 앱 | 같은 컴퓨터에서 실행 중이고 온라인 상태 |

## 2. 패키지 설치

1. Unity에서 **Window → Package Manager**를 엽니다.
2. 왼쪽 위 **+** 버튼을 누릅니다.
3. **Install package from git URL...**을 선택합니다.
4. 아래 주소를 입력하고 **Add**를 누릅니다.

```
https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main
```

최신 베타를 쓰려면 끝의 `#main`을 `#beta`로 바꿉니다.

![Package Manager의 + 메뉴에서 Install package from git URL 선택](images/unity-mcp-01-install-from-git-url.png)

설치가 끝나면 Package Manager의 **In Project** 목록에 MCP for Unity가 나타납니다.

![설치된 MCP for Unity 10.3.0 (Installed From에 깃 주소 표시)](images/unity-mcp-02-package-installed.png)

> Git URL로 설치하면 다운로드 폴더에 파일이 따로 생기지 않습니다. 패키지 주소는 프로젝트의 `Packages/manifest.json`에 기록되고, 실제 파일은 프로젝트의 `Library/PackageCache` 아래에 저장됩니다.

## 3. 설치 확인

다음 중 하나로 확인합니다.

- **Package Manager:** 왼쪽 **In Project** 목록에 **MCP for Unity**가 보이고, 상세 화면의 *Installed From*에 위 깃 주소가 표시됩니다.
- **manifest.json:** `Packages/manifest.json`에 `com.coplaydev.unity-mcp` 항목이 있습니다.
- **Window 메뉴:** **Window → MCP for Unity** 항목이 나타납니다. 패키지가 없는 프로젝트에는 이 메뉴가 없습니다.

![Window 메뉴에 MCP for Unity 항목이 보이는 모습](images/unity-mcp-03-window-menu.png)

## 4. 연결 설정과 확인

1. **Window → MCP for Unity**의 하위 메뉴에서 창을 엽니다.
2. **Connect** 탭에서 아래 상태를 확인합니다.

| 위치 | 정상 상태 |
|---|---|
| Server → Transport | `Stdio` (기본값) |
| Server → Unity Socket Port | `6400` (기본값) |
| Server → 세션 표시 | 초록 불과 **Session Active (프로젝트 이름)** |
| Client Configuration → Client | `Claude Desktop` |
| Client Configuration → 상태 | 초록 불과 **Configured** |

![MCP for Unity 창의 Connect 탭 (Session Active, Configured 상태)](images/unity-mcp-04-connect-window.png)

3. 클라이언트가 **Configured**가 아니면 **Configure All Detected Clients** 버튼을 누릅니다.

> **End Session** 버튼은 연결을 끊습니다. 연습 중에는 누르지 않습니다.

## 5. Claude에서 연결 확인

Claude에게 현재 씬 정보를 읽어 달라고 요청합니다. 성공하면 씬 이름, 경로, 루트 오브젝트 수가 응답으로 옵니다.

이번 연습에서 읽어 온 값:

- 활성 씬: `SampleScene` (`Assets/Scenes/SampleScene.unity`)
- 루트 오브젝트: 5개 (`MainCamera1`, `Directional Light`, `Level`, `Player`, `Camera2`)

## 6. 렌더 파이프라인 확인 (빌트인인지 URP인지)

에셋스토어 에셋은 렌더 파이프라인에 맞아야 하므로 먼저 확인합니다.

- **Project Settings → Graphics:** Default Render Pipeline 칸이 **None**이면 빌트인입니다. URP 에셋이 들어 있으면 URP입니다.
- **머티리얼 셰이더:** `Standard`이면 빌트인, `Universal Render Pipeline/Lit`이면 URP입니다.
- **Claude에게 요청:** 현재 렌더 파이프라인이 무엇인지 읽어 달라고 하면 됩니다. `Dodge`는 파이프라인이 없음(NULL)으로 읽혀 빌트인으로 확인됐고, 씬의 머티리얼도 모두 `Standard`였습니다.

> 새 프로젝트를 만들 때 빌트인으로 쓸 계획이라면 **3D (Built-In Render Pipeline)** 템플릿을 고릅니다. 2D 템플릿으로 시작하면 URP와 2D 렌더러가 기본으로 들어가 3D 라이팅이 적용되지 않습니다.

## 7. 사용 방법

연결이 되면 채팅으로 요청하면 Claude가 Unity에 직접 반영합니다.

- "씬에 Cube를 (0, 1, 3)에 만들어 줘"
- "Player에 붙은 컴포넌트를 알려 줘"
- "씬 구조를 보여 줘"

주의할 점:

- Unity가 해당 프로젝트로 **열려 있어야** 합니다.
- 씬을 바꾸는 작업은 **저장 전까지 에디터에만 반영**됩니다. 되돌리려면 Ctrl+Z를 쓰거나 저장하지 않고 닫습니다.
- 교재 원본 프로젝트에서 연습하면 저장 시 원본 예제가 바뀝니다. **복사본에서 연습**하거나 Git 변경분을 확인합니다.
- 설치와 설정 후에는 `ProjectSettings`, `Packages/manifest.json` 등이 바뀌었을 수 있으므로 커밋 전에 변경 파일을 확인합니다.

## 8. 문제 해결

| 증상 | 원인과 해결 |
|---|---|
| `No Unity Editor instances found` 오류 | Unity가 꺼져 있거나 **MCP가 설치되지 않은 다른 프로젝트**가 열려 있는 경우입니다. MCP를 설치한 프로젝트로 Unity를 엽니다. |
| Window 메뉴에 MCP for Unity가 없음 | 열려 있는 프로젝트에 패키지가 없습니다. 2장의 설치를 진행합니다. 아래 그림처럼 Window 메뉴에 MCP 항목이 없으면 이 경우입니다. |
| 상태가 Connected/Session Active가 아님 | MCP for Unity 창에서 상태를 확인하고, 필요하면 Unity를 재시작합니다. |
| 도구 호출은 되는데 연결이 불안정함 | Claude 데스크톱 앱이 열려 있고 온라인인지 확인합니다. |

![MCP for Unity가 설치되지 않은 프로젝트의 Window 메뉴 (MCP 항목 없음)](images/unity-mcp-05-menu-without-mcp.png)

## 9. 참고 자료

- MCP for Unity 설치 문서: https://coplaydev.github.io/unity-mcp/getting-started/install
- 저장소: https://github.com/CoplayDev/unity-mcp
