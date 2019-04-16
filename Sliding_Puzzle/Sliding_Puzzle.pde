int columns = 3;
int rows = 3;

//Possible values for a certain tile
IntList values = new IntList();

int[][] puzzle = new int[columns][rows];
int[][] goalState = new int[columns][rows];

Node start = new Node();
Node goal = new Node();

int tileWidth;
int tileHeight;

ArrayList<Node> open = new ArrayList<Node>();
ArrayList<Node> closed = new ArrayList<Node>();

ArrayList<Node> path = new ArrayList<Node>();

//To animate the solution
int f = 0;

boolean solve = false;

int correct = 0;

PImage img;
PImage[] tiles = new PImage[columns * rows];

void setup()
{
  size(800, 800);
  tileWidth = width/columns;
  tileHeight = height/rows;

  background(255);

  newPuzzle();

  //Goalstate
  for (int i = 0; i < columns; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      if (i == columns - 1 && j == rows - 1)
      {
        goalState[i][j] = 0;
      } else
      {
        goalState[i][j] = j * columns + i + 1;
      }
    }
  }
  goal.puzzle = goalState;
}

void draw()
{
  if (solve)
  {
    frameRate(1);
    display(path.get(f).puzzle); 
    if (f > 0) f--;
  }
  else 
  {
    display(puzzle);
  }
  
  //Check if user has won
  correct = 0;
  for (int x = 0; x < columns; x++)
  {
    for (int y = 0; y < rows; y++)
    {
      if (puzzle[x][y] == goal.puzzle[x][y])
      {
        correct++;
      }
    }
  }
  if (correct == columns * rows)
  {
    println("Puzzle completed");
  }
}

void newPuzzle()
{
  clearList();
  
  //Keep making new puzzles until a solvable is made
  do
  { 
    for (int i = 0; i < columns * rows; i++)
    {
      values.append(i);
    }

    for (int i = 0; i < columns; i++)
    {
      for (int j = 0; j < rows; j++)
      {
        int index = (int)random(values.size());
        puzzle[i][j] = values.get(index);
        values.remove(index);
      }
    }
  }
  while (!IsSolvable(puzzle));
  start.puzzle = puzzle;
  
  //Load random picture and split it
  int n = (int)random(1, 6);
  img = loadImage("img" + str(n) + ".png");
  for(int i = 0; i < columns * rows; i++)
  {
    int x = i % columns;
    int y = (int)map(i, 0, columns * rows, 0, rows);
    tiles[i] = img.get(x * tileWidth, y * tileHeight, tileWidth, tileHeight);
  }
}

//Display a puzzle
void display(int[][] board)
{
  for (int x = 0; x < columns; x++)
  {
    for (int y = 0; y < rows; y++)
    {
      //Hvis det er det nulte tern skal det være sort, ellers skal ternet udfyldes med et billedestykke
      tint(0);
      int i = columns * rows - 1;
      if(board[x][y] != 0)
      {
        tint(255);
        i = board[x][y] - 1; 
      } 
      image(tiles[i], x * tileWidth, y * tileHeight);
      
      noFill();
      stroke(255);
      strokeWeight(6);
      rect(x * tileWidth, y * tileHeight, tileWidth, tileHeight);
    }
  }
}


void keyPressed()
{
  if (key == 's')
  {
    if(IsSolvable(start.puzzle))
    {
      println("solving....");
      Solve();
      solve = true;  
      f = path.size() - 1;
    } else
    {
      println("Puzzle not solvable");
    }
  }
  
  if (key == 'a')
  {
    frameRate(30);
    solve = false;
    newPuzzle();
    println("New puzzle made");
  }
}

void mouseClicked()
{
  int[] click = ClickedTile();
  int[] blank = BlankTile(puzzle);

  if (IsMovable(click[0], click[1]))
  {
    Swap(click[0], click[1], blank[0], blank[1], puzzle);
  }
}

void clearList()
{
  int m = max(open.size() - 1, closed.size() - 1, path.size() - 1);
  while(open.size() > 0 && closed.size() > 0 && path.size() > 0) 
  {
    if(m < open.size()) open.remove(m);
    if(m < closed.size()) closed.remove(m);
    if(m < path.size()) path.remove(m);
    m--;
  }
}

//Swap to tiles in a given puzzle
void Swap(int x1, int y1, int x2, int y2, int[][] board)
{
  int tempA = board[x1][y1];
  int tempB = board[x2][y2];

  board[x1][y1] = tempB;
  board[x2][y2] = tempA;
}

int[] ClickedTile()
{  
  int mX = (int)map(mouseX, 0, width, 0, columns);
  int mY = (int)map(mouseY, 0, height, 0, rows);

  int[] index = new int[] {mX, mY};

  return index;
}

int[] BlankTile(int[][] board)
{
  int[] index = new int[2];
  for (int x = 0; x < columns; x++)
  {
    for (int y = 0; y < rows; y++)
    {
      if (board[x][y] == 0)
      {
        index[0] = x;
        index[1] = y;
      }
    }
  }
  return index;
}

boolean IsMovable(int x, int y)
{
  int blankX = BlankTile(puzzle)[0];
  int blankY = BlankTile(puzzle)[1];

  int dist = abs(x - blankX) + abs(y - blankY);
  if (dist == 1) return true;

  return false;
}

int[][] CopyBoard(int[][] board)
{
  int[][] copy = new int[columns][rows];
  for (int x = 0; x < columns; x++)
  {
    for (int y = 0; y < rows; y++)
    {
      copy[x][y] = board[x][y];
    }
  }
  return copy;
}

//Swap blanktile with adjacent tiles, and save the new puzzle
ArrayList<Node> ExpandNode(Node n)
{
  ArrayList<Node> children = new ArrayList<Node>();

  int[][] up = CopyBoard(n.puzzle);
  if (BlankTile(up)[1] != 0)
  {
    Swap(BlankTile(up)[0], BlankTile(up)[1], BlankTile(up)[0], BlankTile(up)[1] - 1, up);
    children.add(new Node(up));
  }

  int[][] right = CopyBoard(n.puzzle);
  if (BlankTile(right)[0] != columns - 1)
  {
    Swap(BlankTile(right)[0], BlankTile(right)[1], BlankTile(right)[0] + 1, BlankTile(right)[1], right);
    children.add(new Node(right));
  }

  int[][] down = CopyBoard(n.puzzle);
  if (BlankTile(down)[1] != rows - 1)
  {
    Swap(BlankTile(down)[0], BlankTile(down)[1], BlankTile(down)[0], BlankTile(down)[1] + 1, down);
    children.add(new Node(down));
  }

  int[][] left = CopyBoard(n.puzzle);
  if (BlankTile(left)[0] != 0)
  {
    Swap(BlankTile(left)[0], BlankTile(left)[1], BlankTile(left)[0] - 1, BlankTile(left)[1], left);
    children.add(new Node(left));
  }
  return children;
}

//Get node with lowest F score
Node NextNode()
{
  int check = 99999;
  Node nextNode = new Node();
  for (Node n : open)
  {
    if (n.F() < check)
    {
      check = n.F();
      nextNode = n;
    }
  }
  return nextNode;
}

boolean Contains(ArrayList<Node> list, Node a)
{
  for (Node b : list)
  {
    if (a.Equals(b))
    {
      return true;
    }
  }
  return false;
}

//Udregner heuristikken for en bestemt node
int Heuristic(Node n)
{ 
  int h = 0; 
  for (int x = 0; x < columns; x++)
  {
    for (int y = 0; y < rows; y++)
    {
      int correctX = (n.puzzle[x][y] - 1) % columns;
      int correctY = (int)map(n.puzzle[x][y] - 1, 0, columns * rows, 0, rows);

      h+= abs(correctX - x) + abs(correctY - y);
    }
  }

  return h;
}

//A*
ArrayList<Node> Solve()
{
  open.add(start);
  do
  {
    Node current = NextNode();
    open.remove(current);
    closed.add(current);

    if (Contains(closed, goal)) break;

    for (Node n : ExpandNode(current))
    {
      if (Contains(closed, n)) continue;

      if (Contains(open, n))
      {
        if ((current.g + 1) < n.g)
        {
          n.g = current.g + 1;
          n.parent = current;
        }
      } 
      else
      {
        n.parent = current;
        n.g = n.parent.g + 1;
        n.h = Heuristic(n);
        open.add(n);
      }
    }
  }
  while (open.size() > 0);

  Node end = closed.get(closed.size() - 1);

  return BuildPath(end);
}

ArrayList<Node> BuildPath(Node n)
{
  path.add(n);

  if (n.parent != null)
  {
    BuildPath(n.parent);
  }

  return path;
}

boolean IsSolvable(int[][] board)
{
  int[] puzzleB = new int[columns * rows];

  for (int i = 0; i < columns; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      puzzleB[j * columns + i] = board[i][j];
    }
  }

  int count = 0;
  for (int i = 0; i < columns * rows - 1; i++)
  {
    for (int j = i + 1; j < columns * rows; j++)
    {
      if (puzzleB[i] > puzzleB[j] && puzzleB[j] != 0) 
      {
        count++;
      }
    }
  }

  if (columns % 2 != 0)
  {
    return count % 2 == 0;
  }
  if (columns % 2 == 0 && (rows - BlankTile(board)[1]) % 2 == 0)
  {
    return count % 2 != 0;
  }
  if (columns% 2 == 0 && (rows - BlankTile(board)[1]) % 2 != 0)
  {
    return count % 2 == 0;
  }

  return false;
}
