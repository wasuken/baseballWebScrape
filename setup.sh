#!/bin/sh

rm ./baseball.db
touch baseball.db
sqlite3 baseball.db < import.sql
ruby makeBaseballDB.rb 
