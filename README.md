Taskpacifist
============

A vim script for running taskwarrior.


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

+ display current filter on modeline

+ display matching tasks on modeline
 


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

+ Display Nested lists, of arbitrary depth. First level might be project, next might by tag1, next might be tag2, next might be prio



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

+


swedish keyboard
================

§1234567890+´
qwertyuiopå¨
dfghjklöä'
<zxcvbnm,.-

shift
°!"#€%&/()=?`
QWERTYUIOPÅ^
ASDFGHJKLÖÄ*
ZXCVBNM;:_

alt
¶©@£$∞§|[]≈±´
•Ωé®†µüıœπ˙~
ß∂ƒ¸˛√ªﬁøæ™
≤÷≈ç‹›‘’‚…–

us keyboard
===========

§1234567890-=
qwertyuiop[]
asdfghjkl;'\
`zxcvbnm,./

shift
±!@#$%^&*()_+
QWERTYUIOP{}
ASDFGHJKL:"|
~ZXCVBNM<>?

alt
§¡™£¢∞§¶•ªº–≠
åß∂ƒ©˙∆˚¬…æ«`Ω≈ç√∫˜µ≤≥÷

alt shift
±⁄€‹›ﬁﬂ‡°·‚—±
Œ„´‰ˇÁ¨ˆØ∏”’
ÅÍÎÏ˝ÓÔÒÚÆ
¸˛Ç◊ı˜Â¯¯˘¿

