#!/bin/sh
## kiceDownloader
## kice.re.kr에서 평가원 모의평가 및 수능 답지를 다운로드하는 스크립트입니다. 만약 답지가 서버에 업로드되지 않았다면 업로드될 때가지 무한히 체크해서 업로드가 감지되면 자동으로 다운로드합니다.
## 최근 고사 답지만 다운로드 가능합니다.
VERSION=5

function showHelpMessage(){
	echo "kiceDownloader (Version: ${VERSION}): 평가원 모의평가 및 수능 답지가 업로드될 때가지 무한히 다운로드하는 스크립트 (고3만 지원하며, 지난 고사는 지원하지 않습니다.)"
	echo "이 스크립트를 사용하면서 사용하는 법적 문제에 책임지지 않습니다."
	echo
	echo "--type [시험유형]"
	echo "시험유형을 필수적으로 입력하셔야 합니다. 예로 들면 2018학년도 9월 모의평가 (2017 시행)은 201809sumoi이며, 2017학년도 수능 (2016 시행)은 uneungtnsmd_2017입니다. 형식은 바뀔 수 있으니 평가원 사이트를 참고해 주세요."
	echo
	echo "--subject [과목코드]"
	echo "과목코드를 필수적으로 입력하셔야 합니다. 국어: 1, 수학(가/나형 상관없이): 2, 영어: 3, 한국사: 41, 사회탐구: 42, 과학탐구: 43, 직업탐구: 44, 제2외국어/한문: 5"
	echo
	echo "--server [서버코드]"
	echo "퍙가원 서버 코드를 입력하실 수 있는데 선택적인 사항이며 기본값은 1입니다."
	echo
	echo "--nodelay"
	echo "딜레이 없이 받습니다. 선택적인 사항입니다. 기본값은 1초입니다."
	echo
	echo "예시: 2018학년도 9월 모의평가 수학 답지 다운로드"
	echo "$ ./kiceDownloader.sh --type 201809sumoi --subject 2"
}

function setOption(){
	if [[ "${1}" == "--type" ]]; then
		TestType="${2}"
	fi
	if [[ "${2}" == "--type" ]]; then
		TestType="${3}"
	fi
	if [[ "${3}" == "--type" ]]; then
		TestType="${4}"
	fi
	if [[ "${4}" == "--type" ]]; then
		TestType="${5}"
	fi
	if [[ "${5}" == "--type" ]]; then
		TestType="${6}"
	fi
	if [[ "${6}" == "--type" ]]; then
		TestType="${7}"
	fi
	if [[ "${7}" == "--type" ]]; then
		TestType="${8}"
	fi
	if [[ "${8}" == "--type" ]]; then
		TestType="${9}"
	fi

	if [[ "${1}" == "--subject" ]]; then
		TestSubject="${2}"
	fi
	if [[ "${2}" == "--subject" ]]; then
		TestSubject="${3}"
	fi
	if [[ "${3}" == "--subject" ]]; then
		TestSubject="${4}"
	fi
	if [[ "${4}" == "--subject" ]]; then
		TestSubject="${5}"
	fi
	if [[ "${5}" == "--subject" ]]; then
		TestSubject="${6}"
	fi
	if [[ "${6}" == "--subject" ]]; then
		TestSubject="${7}"
	fi
	if [[ "${7}" == "--subject" ]]; then
		TestSubject="${8}"
	fi
	if [[ "${8}" == "--subject" ]]; then
		TestSubject="${9}"
	fi

	if [[ "${1}" == "--server" ]]; then
		KiceServer="${2}"
	fi
	if [[ "${2}" == "--server" ]]; then
		KiceServer="${3}"
	fi
	if [[ "${3}" == "--server" ]]; then
		KiceServer="${4}"
	fi
	if [[ "${4}" == "--server" ]]; then
		KiceServer="${5}"
	fi
	if [[ "${5}" == "--server" ]]; then
		KiceServer="${6}"
	fi
	if [[ "${6}" == "--server" ]]; then
		KiceServer="${7}"
	fi
	if [[ "${7}" == "--server" ]]; then
		KiceServer="${8}"
	fi
	if [[ "${8}" == "--server" ]]; then
		KiceServer="${9}"
	fi

	if [[ "${1}" == "--nodelay" || "${2}" == "--nodelay" || "${3}" == "--nodelay" || "${4}" == "--nodelay" || "${5}" == "--nodelay" || "${6}" == "--nodelay" || "${7}" == "--nodelay" || "${8}" == "--nodelay" || "${9}" == "--nodelay" ]]; then
		NO_DELAY=YES
	fi

	if [[ -z "${TestType}" || -z "${TestSubject}" ]]; then
		showHelpMessage
		exit 0
	fi

	if [[ -z "${KiceServer}" ]]; then
		KiceServer=1
	fi
	DOWNLOAD_URL="http://webfs${KiceServer}.kice.re.kr/${TestType}/$(($(date +"%Y")+1))_${TestSubject}.pdf"
}

function showSummary(){
	showLines "*"
	echo "요약 (Version: ${VERSION})"
	showLines "-"
	echo "시험코드: ${TestType} ($(($(date +"%Y")+1))학년도)"
	echo "과목코드: ${TestSubject}"
	echo "링크: ${DOWNLOAD_URL}"
	showLines "*"
}

function downloadFile(){
	COUNT=0
	FILE_COUNT=1
	while(true); do
		if [[ -f "/tmp/kicefile${FILE_COUNT}.pdf" ]]; then
			FILE_COUNT=$((${FILE_COUNT}+1))
		else
			FILE_PATH="/tmp/kicefile${FILE_COUNT}.pdf"
			break
		fi
	done
	while(true); do
		COUNT=$((${COUNT}+1))
		echo "다운로드 중... (${COUNT})"
		if [[ -f "${FILE_PATH}" || -d "${FILE_PATH}" ]]; then
			rm -rf "${FILE_PATH}"
		fi
		curl -# -o "${FILE_PATH}" "${DOWNLOAD_URL}"
		if [[ "${COUNT}" == 1 ]]; then
			echo "파일 확인 중..."
			for VALUE in $(cat "${FILE_PATH}"); do
				if [[ "${VALUE}" == "XHTML" ]]; then
					IS_FAKE_FILE=YES
					break
				fi
			done
			if [[ "${IS_FAKE_FILE}" == YES ]]; then
				FILE_SHA1="$(shasum "${FILE_PATH}" | awk '{ print $1 }')"
			else
				echo "완료! 답지 파일 여는 중..."
				open "${FILE_PATH}"
				exit 0
			fi
		else
			echo "파일 확인 중..."
			if [[ ! "$(shasum "${FILE_PATH}" | awk '{ print $1 }')" == "${FILE_SHA1}" ]]; then
				echo "완료! 답지 파일 여는 중..."
				open "${FILE_PATH}"
				exit 0
			fi
		fi
		if [[ ! "${NO_DELAY}" == YES ]]; then
			sleep 1
		fi
	done
}

function showLines(){
	PRINTED_COUNTS=0
	COLS=`tput cols`
	if [[ "${COLS}" -ge 1 ]]; then
		while [[ ! ${PRINTED_COUNTS} == $COLS ]]; do
			printf "$1"
			PRINTED_COUNTS=$((${PRINTED_COUNTS}+1))
		done
		echo
	fi
}

setOption "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}"
showSummary
downloadFile
