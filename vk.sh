#!/bin/bash

API_TOKEN=''
API_VERSION='5.103'

################ COLORS ################
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Orange='\033[0;33m'    # Orange
########################################

################ FONT STYLE ################
ITALIC='\033[3m'
BOLD='\033[1m'
############################################

NC='\033[0m'              # No Color

CLIENT_VERSION='1.0'

#################### WELCOME ####################

echo -e "${On_Red}VKClient ${CLIENT_VERSION}${NC}\n"
echo -e "${BOLD}Загружаю $1 сообщений...${NC}\n"

####################   END   ####################


response=$(curl -s 'https://api.vk.com/method/messages.getConversations' -d "access_token=$API_TOKEN&v=$API_VERSION&count=$1&extended=1" )

# Количество непрочитанных бесед
unreadCountMessages=$(jq '.response.unread_count' <<< "$response")

# Общее кол-во диалогов
count=$(jq '.response.count' <<< "$response")

echo -e "${BOLD}Сообщения:${NC}"
echo -e "${On_Green}Непрочитанных диалогов:${NC} ${unreadCountMessages}"
echo -e "${On_Green}Всего бесед: ${NC} ${count}\n"

################## Сообщения ##################

items=$(jq -r ".response.items | keys | .[]" <<< "$response")

for item in $items
  do
    value=$(jq -r ".response.items[$item]" <<< "$response");
    userId=$(jq -r '.last_message.from_id' <<< "$value")
    message=$(jq -r '.last_message' <<< "$value")
    messageText=$(jq -r '.text' <<< "$message")

    [[ $messageText = '' ]] && messageText="${ITALIC}Вложение${NC}" || messageText="$messageText"

    profile=$(jq -r ".response.profiles[] | select(.id==$userId)" <<< "$response")
    displayName=$(jq -r '.screen_name' <<< "$profile")
    firstName=$(jq -r '.first_name' <<< "$profile")
    lastName=$(jq -r '.last_name' <<< "$profile")

    echo -e "${BOLD}${On_Orange}$firstName $lastName ($displayName)${NC}: $messageText"
  done

##############################################
