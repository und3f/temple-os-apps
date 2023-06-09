$SP,"<X>",BI=1$




$SP,"<O>",BI=2$




Cd(__DIR__);;
#include "TicTacToe"

#define glblSize 350
#define SPRITE_SIZE33.0

U8 *marks[2] = {$IB,"<X>",BI=1$, $IB,"<O>",BI=2$};

class Point
{$ID,2$
I64 x, y;
$ID,-2$};


class Rectangle
{
$ID,2$Point tl, br;
$ID,-2$};


class RastrSprites
{
  U8**marks;
} sprites;


Bool IsPointInRect(Point *p, Rectangle *rect){$ID,2$
return rect->tl.x <p->x < rect->br.x
	&& rect->tl.y <p->y<rect->br.y;
$ID,-2$}

U0 GetMousePosition(CTask *task, Point *p){$ID,2$
p->x = ms.pos.x - task->pix_left;
p->y = ms.pos.y - task->pix_top;
$ID,-2$}

U8 GetMouseBoardPosition(CTask *task, Rectangle*board){
  I64 w_width = board->br.x - board->tl.x;
  I64 step = (w_width + 1) / BOARD_SIZE;
  Point msPos;
  GetMousePosition(task, &msPos);

  if (!IsPointInRect(&msPos, board)){
    return 0xff;
 }

  return ((msPos.y - board->tl.y) / step)*BOARD_SIZE
	+(msPos.x - board->tl.x) / step;
}

U0 DrawBoard(Rectangle *p, CDC*dc, U8 activeCell = 0xff) {
  I64 size = p->br.x - p->tl.x;

  I64 step = size/BOARD_SIZE;

  U8 x, y;
  dc->color = DKGRAY;
  for (x = 0; x <BOARD_SIZE; x++) {
    for (y = 0; y <BOARD_SIZE; y++){
      Rectangle r;
      r.tl.x = p->tl.x +x *step;
      r.tl.y = p->tl.y +y *step;
      r.br.x = r.tl.x + step;
      r.br.y = r.tl.y +step;

      if (x +y *BOARD_SIZE== activeCell) {
        dc->color = LTGRAY;
        GrRect(dc, r.tl.x +1, r.tl.y +1, step - 1, step - 1);
      }

      U8 cellState = gameState.board[y *BOARD_SIZE +x];
      if (cellState < NUM_OF_PLAYERS){
        Sprite3(dc, r.tl.x, r.tl.y, 0, sprites.marks[cellState]);
      }

      dc->color = DKGRAY;
      GrLine(dc, r.tl.x, r.tl.y, r.br.x, r.tl.y);
      GrLine(dc, r.tl.x, r.br.y, r.br.x, r.br.y);
      GrLine(dc, r.tl.x, r.tl.y, r.tl.x, r.br.y);
      GrLine(dc, r.br.x, r.tl.y, r.br.x, r.br.y);
    }
  }
}

U0 DrawStrokeLine(CDC*dc, Rectangle *board){
  // TODO:strike through
}

Rectangle*placeBoard(CTask *task, I64 size)
{$ID,2$
Rectangle *board = CAlloc(sizeof(Rectangle));

board->tl.x = (task->pix_width - size)>>1;
board->tl.y = (task->pix_height - size)>>1;
board->br.x = board->tl.x +size;
board->br.y = board->tl.y +size;

return board;
$ID,-2$}

U0 DrawIt(CTask *task,CDC *dc)
{$ID,2$
Rectangle *board = placeBoard(task, glblSize);

U8 activeCell = GetMouseBoardPosition(task, board);
if (gameState.board[activeCell] != 0xff) {
  activeCell = 0xff;
}

// Left mouse button Released
if (activeCell != 0xff
    &&ms_last.lb &&!ms.lb){
  gameMove(&gameState, activeCell);
}

DrawBoard(board, dc, activeCell);

Free(board);
$ID,-2$}

U0 PrepareGraphics(I64 cellSize){
  I64 r[4][4];
  Mat4x4IdentEqu(r);
  Mat4x4Scale(r, ToF64(cellSize) / SPRITE_SIZE);
  sprites.marks = CAlloc(sizeof(U8*)*NUM_OF_PLAYERS);
  U8 i;
  for (i = 0; i <sizeof(marks)/sizeof(U8*); i++){
    sprites.marks[i] = SpriteTransform(marks[i], r);
  }
}

U0 DestroyGraphics(){
  I64 i;
  for (i = 0; i <sizeof(marks)/sizeof(U8*); i++){
    Free(sprites.marks[i]);
  }
  Free(sprites.marks);
}

U0 CheckKeyboard(){
  I64 keyDown = ScanChar();
  if (keyDown!= 0){
    if (keyDown == CH_ESC||keyDown == CH_SHIFT_ESC){
      gameState.state = STATE_ABORT;
    }
  }
}

U8 *playerLabel[NUM_OF_PLAYERS] = {"Cross", "Nought"};
U0 TicTacToeUI(){$ID,2$
StrCpy(Fs->task_title, "Tic Tac Toe");
AutoComplete;
SettingsPush;
WinBorder;
DocClear;
WinMax;
PrepareGraphics(glblSize / BOARD_SIZE);
PrepareGame;

Fs->draw_it = &DrawIt;

while (gameState.state == STATE_WAIT_PLAYER){
  CheckKeyboard();
  Yield;
}

Fs->draw_it = NULL;

if (gameState.state != STATE_ABORT){
  CDC*dc = DCAlias;
  DCFill(dc);
  Rectangle *board = placeBoard(Fs, glblSize);
  DrawBoard(board, dc);
  
  if (gameState.state == STATE_WIN){
    DrawStrokeLine(dc, board);
    "%s won!\n", playerLabel[gameState.curPlayer];
  } else {
    "It is a tie!\n";
  }
  PressAKey;

  Free(board);  
  DCDel(dc);
  DCFill;
}

DestroyGraphics;
DestroyGame;

SettingsPop;
$ID,-2$}        -         
            
                    $                     S;�0��� 