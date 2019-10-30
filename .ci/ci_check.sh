#!/bin/bash

skip_check_words="ignore check"

LOG_ERROR() {
    content=${1}
    echo -e "\033[31m"${content}"\033[0m"
}

function check_PR()
{
    local commits=$(git rev-list --count HEAD^..HEAD)
    local unique_commit=$(git log --format=%s HEAD^..HEAD | sort -u | wc -l)
    if [ ${unique_commit} -ne ${commits} ];then
        LOG_ERROR "${commits} != ${unique_commit}, please make commit message unique!"
        exit 1
    fi
}

check_PR
