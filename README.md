Taskpacifist
============

A vim script for running taskwarrior.

My tag prefixes

 = project
 
 % area of focus / area of responsability

 $ client

 @ context  

Feature wishlist
================

really easy
-----------

+ syntax highlighting 
  
  + make id darker
  + make | darker
  + highlight current line

+ Delete a tag (autocomplete) from current task

+ Delete same tag as last time

+ display tags in list

 


a little harder
---------------

+ display current filter in mode line

+ Make task dependent on other task
  
+ Add task that fulfills currently active filter (for project and tags at least)

+ Add tag todotoday_<todaysdate> to a task (eg todotoday_20120829)

+ List all tasks tagged todotoday_<todaysdate>

+ Remove all task tagged todotoday_* unless tag is todotoday_<todaysdate>

+ Add tag to filter (allow autocomplete)

+ Add priority:1 to current filterset

+ Add pri:1 or pri:2  to current filterset

+ Add pri:1 or pri:2 or pri:3 to current filterset
  
+ Add pri:1 or pri:2 or pri:3 or pri:none to current filterset

+ Toggle columns for display on/off

+ Expand/contract width off columns



suitable tag prefix keys
========================
§  ¨ < >
! # % & / = ?
^ * 
; _
¶ @ £ $ ≈ ± ø 
÷


context/requisite @
project ¶ #
client  
area of responsability % 
time estimate ^
subproject ¶¶

priority !

Not suitable
- + used by taskwarrior to separate out tags from nontags
| might confuse the shell
: also part of taskwarrior syntax

