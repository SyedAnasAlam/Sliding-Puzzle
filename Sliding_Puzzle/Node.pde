//Et node objekt, anvendes til løsning af puslespillet
class Node
{
  int[][] puzzle;
  int h;
  int g;
  Node parent;
  
  Node(int[][] Puzzle)
  {  
    puzzle = Puzzle;
  }
  
  //Tom konstruktør
  Node() { }
  
  //Returnerer F scoren 
  int F()
  {
    return g + h;
  }
  
  //Funktion til at tjekke om to noder er ens
  boolean Equals(Node n)
  {
    int count = 0;
    for(int i = 0; i < columns; i++)
    {
      for(int j = 0; j < rows; j++)
      {
        if(n.puzzle[i][j] == this.puzzle[i][j])
        {
          count++;
        }
      }
    }
    
   if(count == columns * rows)
   {
     return true;
   }
   return false;
  }
}
