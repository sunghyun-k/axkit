# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

AXKit은 macOS Accessibility API(ApplicationServices)의 Swift 래퍼 라이브러리입니다. 저수준 C API인 `AXUIElement`를 타입 안전한 Swift API로 변환합니다.

## 빌드 명령어

```bash
# 빌드
swift build
```

## 대규모 코드베이스 분석 시 지침

1. 디렉토리 구조 먼저 분석 후 반환 (서브에이전트)
2. 각 역할별 디렉토리 구조를 병렬로 다시 분석하여 주요 파일 위치에 대해 반환 (병렬 서브에이전트)
3. 각 주요 파일을 읽고 핵심 구현 방식에 대해 설명 (메인 컨텍스트)
