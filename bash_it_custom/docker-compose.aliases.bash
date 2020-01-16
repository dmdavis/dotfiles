#!/usr/bin/env bash

if [[ $(command -v docker-compose) != "" ]]
then
	alias dcoud="docker-compose up -d"
	alias dcox="docker-compose down"
fi