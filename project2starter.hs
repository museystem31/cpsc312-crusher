-- CPSC 312 - Project 2
-- by Khurram Ali Jaffery

-- Student #1, Name: Kelvin Yip
-- Student #1, Student #: 18016121
-- Student #1, ugrad ID: s8u8

-- Student #2, Name: Gisli Thor Thordarson
-- Student #2, Student #: 73996150
-- Student #2, ugrad ID: m8j0b

-- Student #3, Name: Chun-Wei Yen
-- Student #3, Student #: 33425125
-- Student #3, ugrad ID: s2u9a

-- Main Components:
-- minimax algorithm
-- a board evaluator
-- state search
-- movement generators (and by extension, tree generator, new state generator)
-- crusher
-- custom data types (already done)

-- Piece is a data representation of possible pieces on a board
-- where D is an empty spot on the board
--		 W is a piece of the White player
--		 B is a piece of the Black player
--

data Piece = D | W | B deriving (Eq, Show)

--
-- Point is a tuple of 2 elements
-- representing a point on a grid system
-- where the first element represents the x coordinate
--       the second element represents the y coordinate
--

type Point = (Int, Int)

--
-- Tile is a tuple of 2 elements
-- representing what a point is occupied by
-- where the first element represents a piece
--       the second element represents a point
--

type Tile  = (Piece, Point)

--
-- Board is a list of Pieces, thus it is an internal representation
-- of the provided string representation of the board, it maintains
-- the same order as the string representation of the board
--

type Board = [Piece]

--
-- Grid is a list of Points, thus it is an internal representation
-- of the hexagonal grid system translated into a coordinate
-- system to easily maintain and make moves on the board
--

type Grid = [Point]

--
-- State is a list of Tile, thus it is an internal representation precisely
-- for the purposes of zipping the board and the grid together in order
-- to keep easier track of the effects on the pieces of making moves on grid
--

type State = [Tile]

--
-- Next is a data representation for storing and passing around information within
-- the tree generating function, allowing it to correctly generate new children
--
-- Next consists of 4 elements
-- where usedDepth is an integer reprsenting the current depth level
--		 newBoard is the next board to add to the tree
-- 		 seenBoards is the updated history to avoid possible future trouble boards
-- 		 cplayer is the current player for whom the board was generated for
--

data Next a = Next {usedDepth :: Int, newBoard :: a, seenBoards :: [a], cplayer :: Piece}

--
-- Tree is a data representation for the search tree, it is an extention of
-- the rose tree widely used for implementing such unequally branched search trees
--
-- Tree consists of 3 elements
-- where depth is an integer representing the depth level of the node
-- 		 board is the game state at that node
-- 		 nextBoards are the child nodes of the current node
--

data Tree a = Node {depth :: Int, board :: a, nextBoards :: [Tree a]} deriving (Show)

--
-- BoardTree is the internal representation of the search tree of the given board
-- that is to be generatated for correctly implementing the minimax algorithm.
--

type BoardTree = Tree Board

--
-- Slide is a tuple of 2 elements
-- an internal representation of a slide
-- where the first element represents the point to move from
-- 		 the second element represents the adjacent point to move to
--

type Slide = (Point,Point)

--
-- Jump is a tuple of 2 elements
-- where the first element represents the point to move from
-- an internal representation of a leap
-- 		 the second element represents the adjacent point to move over
--		 the third element represents the point to move to
--

type Jump = (Point,Point,Point)

--
-- Move is a tuple of 2 elements
-- an internal representation of a move
-- where the first element represents the point to move from
-- 		 the second element represents the point to move to
--
-- Note: in essence it is the same as a slide however the idea
--		 is that a jump can be reduced to a move as in effect
--		 nothing happens the point moved over in a jump
--

type Move = (Point,Point)

--
-- Some test results to see what functions are producing
--
--run = crusher ["W------------BB-BBB","----W--------BB-BBB","-W-----------BB-BBB"] 'W' 2 3
grid0 = generateGrid 3 2 4 []
slides0 = generateSlides grid0 3
jumps0 = generateLeaps grid0 3
board0 = sTrToBoard "WWW-WW-------BB-BBB"
newBoards0 = generateNewStates board0 [] grid0 slides0 jumps0 W
tree0 = generateTree board0 [] grid0 slides0 jumps0 W 1 3
heuristic0 = boardEvaluator W [] 3
heuristic1 = boardEvaluator B [board0] 3

-- play function written by an anonymous user on piazza.
-- reference link @369 on piazza
play :: [String] -> Char -> Int -> Int -> IO ()
play history@(current:old) player depth n
  | gameOver (sTrToBoard current) (map sTrToBoard old) n = putStrLn "Game over."
  | otherwise = do
       let history'@(new:_) = crusher history player depth n
       putStrLn $ player:" played: " ++ new
       play history' (if player == 'W' then 'B' else 'W') depth n

-- some items useful for testing:
grid3::[Point]
grid3 = [(0,0),(1,0),(2,0),(0,1),(1,1),(2,1),(3,1),(0,2),(1,2),(2,2),(3,2),(4,2),(0,3),(1,3),(2,3),(3,3),(0,4),(1,4),(2,4)]

grid2:: [Point]
grid2 = [(0,0),(1,0),(0,1),(1,1),(2,1),(0,2),(1,2)]

state2 :: State
state2 = [(B,(0,0)),(D, (1,0)), (D, (0,1)),(B,(1,1)),(D,(2,1)),(W,(0,2)),(D,(1,2))]

state2_from :: State
state2_from = [(B,(0,0)),(B,(1,0)),(D,(0,1)),(B,(1,1)),(D,(2,1)),(W,(0,2)),(D,(1,2))]

board2 :: Board
board2 = [B,D,D,B,D,W,D]


history2 = []

moves2 :: [Move]
moves2 = [((0,0),(1,0)),((0,0),(0,1)),((0,0),(1,2)),((1,1),(2,1)),((1,1),(1,2))]

slides:: [Slide]
slides = [((1,4),(1,5)),((1,4),(2,4)),((1,4),(0,5)),((1,4),(2,3)),((1,4),(1,3)),((1,4),(0
 ,4))]

slides2 :: [Slide]
slides2 = [((0,0),(1,0)),((0,0),(1,1)),((0,0),(0,1)),((1,0),(0,0)),((1,0),(2,1)),((1,0),
 (1,1)),((0,1),(0,0)),((0,1),(1,1)),((0,1),(0,2)),((1,1),(0,1)),((1,1),(0,0)),((1,1),
 (1,0)),((1,1),(2,1)),((1,1),(1,2)),((1,1),(0,2)),((2,1),(1,1)),((2,1),(1,0)),
 ((2,1),(1,2)),((0,2),(0,1)),((0,2),(1,1)),((0,2),(1,2)),((1,2),(0,2)),((1,2),(1,1)),
 ((1,2),(2,1))]

jumps2 :: [Jump]
jumps2 = [((0,0),(1,1),(1,2)),((1,0),(1,1),(0,2)),((0,1),(1,1),(2,1)),((2,1),(1,1),(0,1)),
 ((0,2),(1,1),(1,0)),((1,2),(1,1),(0,0))]

--
-- crusher
--
-- This is the main function that 'plays' the game. It takes the current board,
-- the history of board states, the player (either 'W' or 'B'), the depth of
-- the search tree, and the dimension of the board.
--
-- The board used is a regular hexagonal grid. The value provided for the
-- dimension input is just an integer which represents the length of each side.
--
-- Usage:
--  crusher [current_board|history] player depth dimension
--
-- Example:
--  crusher ["WWW-WW-------BB-BBB"] 'W' 2 3
--
-- Returns:
--  List of string as the board state with the next move at the front
--

crusher :: [String] -> Char -> Int -> Int -> [String]
crusher (current:old) p d n = -- To Be Completed
    -- if the game is over (and stateSearch returns the current board), then we
    -- make no move and return the input board history. This condition was
    -- unspecified in the project specification so just do what would make
    -- sense
    if (gameOver curBoard history n)
        then current:old
        else
            (boardToStr board):current:old
            where curBoard = sTrToBoard current
                  history = losTrToloBoard old
                  board = stateSearch curBoard
                                      history
                                      grid slides jumps (charToPiece p) d n
                          -- generate a regular hexagonal grid
                          where grid = (generateGrid n (n-1) (2*(n-1)) [])
                                slides = (generateSlides grid n)
                                jumps = (generateLeaps grid n)

--
-- gameOver
--
-- This function determines whether the game is over. It takes the current
-- board the game's board state history along with the dimension of the board.
--
-- The game is over if any of the following conditions are met:
--  * The current board is a repeat of a previous board state
--  * White has less than n pieces remaining
--  * Black has less than n pieces remaining
--
--  Example:
--      gameOver [W,W,D,D,D,B,B] [] 2
--
--  Return:
--      true if the game is over
--      false if it isn't
--

gameOver :: Board -> [Board] -> Int -> Bool
gameOver board history n  -- To Be Completed
    | elem board history        = True
    | countPiece board W < n    = True
    | countPiece board B < n    = True
    | otherwise                 = False

-- This is a helper function that recursively counts the number of Piece there
-- are on the board.
countPiece :: Board -> Piece -> Int
countPiece board piece
    | null board                = 0
    -- if the head is piece, then add one and check tail
    | (head board) == piece     = 1 + countPiece (tail board) piece
    -- otherwise, just check the tail
    | otherwise                 = countPiece (tail board) piece

--
-- sTrToBoard
--
-- This function consumes a list of characters which can be either 'W' or 'B'
-- or '-' and converts them to a list of pieces, i.e W or B or D respectively
--
-- Arguments:
-- -- s: the String to convert into piece-wise representation
--
-- Note: This function would convert "WWW-WW-------BB-BBB" to
-- 	     [W,W,W,D,W,W,D,D,D,D,D,D,D,B,B,D,B,B,B]
--
-- Returns: the Board corresponding to the string
--

sTrToBoard :: String  -> Board
sTrToBoard s = map (\ x -> check x) s
    where
        check 'W' = W
        check 'B' = B
        check '-' = D

-- This function takes a list of String and converts them to a list of Board.
-- It applies the function sTrToBoard to each of the String in the list.
losTrToloBoard :: [String] -> [Board]
losTrToloBoard los = map (\x -> sTrToBoard x) los

-- This function takes character and converts it to a Piece
-- Precondition: Assume the input is either 'W' or 'B'
charToPiece :: Char -> Piece
charToPiece c =
    if c == 'W'
        then W
        else B

--
-- boardToStr
--
-- This function consumes a board which is a list of either W or B  or D and
-- converts them to a list of characters, i.e 'W' or 'B' or 'D' respectively
--
-- Arguments:
-- -- b: the Board to convert into char-wise representation
--
-- Note: This function would convert [W,W,W,D,W,W,D,D,D,D,D,D,D,B,B,D,B,B,B]
-- 	     to "WWW-WW-------BB-BBB"
--
-- Returns: the String corresponding to the board
--

boardToStr :: Board -> String
boardToStr b = map (\ x -> check x) b
 where
  check W = 'W'
  check B = 'B'
  check D = '-'

--
-- generateGrid
--
-- This function consumes three integers (described below) specifying how to
-- properly generate the grid and also a list as an accumulator; to generate a
-- regular hexagon of side length n, pass n (n- 1) (2 * (n - 1)) and []
--
-- Arguments:
-- -- n1: one more than max x-coordinate in the row, initialized always to n
-- -- n2: the number of rows away from the middle row of the grid
-- -- n3: the current y-coordinate i.e the current row number
-- -- acc: an accumulator that keeps track of accumulating rows of grid
--		   initialized to []
--
-- Note: This function on being passed 3 2 4 [] would produce
--		 [(0,0),(1,0),(2,0)
--		  (0,1),(1,1),(2,1),(3,1)
--		  (0,2),(1,2),(2,2),(3,2),(4,2)
--		  (0,3),(1,3),(2,3),(3,3)
--		  (0,4),(1,4),(2,4)]
--
-- Returns: the corresponding Grid i.e the acc when n3 == -1
--

generateGrid :: Int -> Int -> Int -> Grid -> Grid
generateGrid n1 n2 n3 acc
 | n3 == -1 = acc
 | otherwise = generateGrid nn1 (n2 - 1) (n3 - 1) (row ++ acc)
  where
   row = map (\ x -> (x,n3)) [0 .. (n1 - 1)]
   nn1 = if n2 > 0 then n1 + 1 else n1 - 1

--
-- generateSlides
--
-- This function consumes a grid and the size of the grid, accordingly
-- generates a list of all possible slides from any point on the grid to
-- any adjacent point on the grid
--
-- Arguments:
-- -- b: the Grid to generate slides for
-- -- n: an Integer representing the dimensions of the grid
--
-- Note: This function is only called at the initial setup of the game,
-- 		 it is a part of the internal representation of the game, this
--		 list of all possible slides is only generated once; and when
-- 		 generating next moves, the program decides which slides out of
--		 all these possible slides could a player actually make
--
-- Returns: the list of all Slides possible on the given grid
--

---------completed----------
generateSlides :: Grid -> Int -> [Slide]
generateSlides [] n = []
generateSlides b n = generateSlides_helper b b n

-- a helper function to generateSlides, in which it generates slides for all the
-- points on the grid.
generateSlides_helper b points_left n
 | points_left == [] = []
 | otherwise =
    (generateValidSlidesForOnePoint b (generateAllSlidesForOnePoint (head points_left) n)) ++
     (generateSlides_helper b (tail points_left) n)

-- given a grid and a list of slides of a point, filters out all the invalid slides
-- based on the grid, and returns that list of valid slides in the end.
generateValidSlidesForOnePoint:: Grid -> [Slide] -> [Slide]
generateValidSlidesForOnePoint b slides
 | b == [] = []
 | slides == [] = []
 | elem (snd (head slides)) b = (head slides):(generateValidSlidesForOnePoint b (tail slides))
 | otherwise = (generateValidSlidesForOnePoint b (tail slides))

-- given a point, returns all the slides for that point
-- the slides for a given point * is listed in the order of:
--           2_ 3_
--         1_  *_ 4_
--           6_ 5_
-- the reason for this ordering is for easiness of getting leap points
-- as this function will also be used as a helper function for getting
-- leap points.
-- Different formula is applied to different points. There are three cases:
-- 1. point is above the middle line
-- 2. point is below the middle line
-- 3. point is on the middle line
generateAllSlidesForOnePoint :: Point -> Int -> [Slide]
generateAllSlidesForOnePoint p int
 | (snd p) < (div (2*n-2) 2) =
      [(p, ((fst p)-1, snd p)),
       (p, (fst lp, (snd lp)-1)),
       (p, (fst p, (snd p)-1)),
       (p, ((fst p)+1, snd p)),
       (p, (fst rp, (snd rp)+1)),
       (p, (fst p, (snd p)+1))]
 | (snd p) > (div (2*n-2) 2) =
      [(p, ((fst p)-1, snd p)),
       (p, (fst p, (snd p)-1)),
       (p, (fst rp, (snd rp)-1)),
       (p, ((fst p)+1, snd p)),
       (p, (fst p, (snd p)+1)),
       (p, (fst lp, (snd lp)+1))]
 | otherwise =
      [(p, ((fst p)-1, snd p)),
       (p, (fst lp, (snd lp)-1)),
       (p, (fst p, (snd p)-1)),
       (p, ((fst p)+1, snd p)),
       (p, (fst p, (snd p)+1)),
       (p, (fst lp, (snd rp)+1))]
 where
 n = fromIntegral int
 lp = ((fst p)-1, snd p)
 rp = ((fst p)+1, snd p)

--
-- generateLeaps
--
-- This function consumes a grid and the size of the grid, accordingly
-- generates a list of all possible leaps from any point on the grid over
-- any adjacent point on the grid to any point next to the adjacent point
-- such that it is movement in the same direction
--
-- Arguments:
-- -- b: the Grid to generate leaps for
-- -- n: an Integer representing the dimensions of the grid
--
-- Note: This function is only called at the initial setup of the game,
-- 		 it is a part of the internal representation of the game, this
--		 list of all possible leaps is only generated once; and when
-- 		 generating next moves, the program decides which leaps out of
--		 all these possible leaps could a player actually make
--
-- Returns: the list of all Jumps possible on the given grid
--

---------completed----------
generateLeaps :: Grid -> Int -> [Jump] -- To Be Completed
generateLeaps [] n = []
generateLeaps b n = generateLeaps_helper b b n

-- a helper function to generateSlides, in which it generates leaps for all the
-- points on the grid.
generateLeaps_helper b points_left n
 | points_left == [] = []
 | otherwise =
    (generateValidLeapsForOnePoint b (generateAllLeapsForOnePoint (head points_left) n)) ++
     (generateLeaps_helper b (tail points_left) n)

-- given a grid and a list of leaps of a point, filters out all the invalid leaps
-- based on the grid, and returns that list of valid leaps in the end.
generateValidLeapsForOnePoint:: Grid -> [Jump] -> [Jump]
generateValidLeapsForOnePoint b leaps
 | b == [] = []
 | leaps == [] = []
 | elem (get_jump_thd (head leaps)) b = (head leaps):(generateValidLeapsForOnePoint b (tail leaps))
 | otherwise = (generateValidLeapsForOnePoint b (tail leaps))

-- given a point, returns all the leaps for that point in the order of:
-- starting from the left point and go clockwise.
generateAllLeapsForOnePoint :: Point -> Int -> [Jump]
generateAllLeapsForOnePoint p n =
 [(p, (snd (one s)), ((fst (snd (one s)))-1, snd (snd (one s)))),
  (p, (snd (two s)), (fortwo (snd (two s)) n)),
  (p, (snd (three s)), (forthree (snd (three s)) n)),
  (p, (snd (four s)), ((fst (snd (four s)))+1, snd (snd (four s)))),
  (p, (snd (five s)), (forfive (snd (five s)) n)),
  (p, (snd (six s)), (forsix (snd (six s)) n))]
 where
 s = generateAllSlidesForOnePoint p n

-- the slides for a given point * is listed in the order of:
--           2_ 3_
--         1_  *_ 4_
--           6_ 5_
-- in order to get leaps for *, point 1, 2, 3, 4, 5, 6 will be used for
-- determining the leap points. However, depending on where point 1-6 are,
-- there need to be different formulas for different points under different
-- conditions for getting the leap points. See the following:
fortwo :: Point -> Int -> Point
fortwo p n
 | (snd p) <= (div (2*n-2) 2) = ((fst p)-1, (snd p)-1)
 | otherwise = (fst p, (snd p)-1)

forthree :: Point -> Int -> Point
forthree p n
 | (snd p) <= (div (2*n-2) 2) = (fst p, (snd p)-1)
 | otherwise = ((fst p)+1, (fst p)-1)

forfive :: Point -> Int -> Point
forfive p n
 | (snd p) >= (div (2*n-2) 2) = (fst p, (snd p)+1)
 | otherwise = ((fst p)+1, (snd p)+1)

forsix :: Point -> Int -> Point
forsix p n
 | (snd p) >= (div (2*n-2) 2) = ((fst p)-1, (snd p)+1)
 | otherwise = (fst p, (snd p)+1)

-- because generateAllLeapsForOnePoint uses a list of slides of a given point
-- the following functions are to help accessing particular elements in the list.
one :: [Slide] -> Slide
one list = (head list)
two :: [Slide] -> Slide
two list = (head (tail list))
three :: [Slide] -> Slide
three list = (head (tail (tail list)))
four :: [Slide] -> Slide
four list = (head (tail(tail(tail list))))
five :: [Slide] -> Slide
five list = (head (tail(tail(tail (tail list)))))
six :: [Slide] -> Slide
six list = (head (tail(tail(tail (tail (tail list))))))

-- get the first, second, or third element from a jump
get_jump_thd:: Jump -> Point
get_jump_thd (a,b,c) = c

get_jump_fst:: Jump -> Point
get_jump_fst (a,b,c) = a

get_jump_snd:: Jump -> Point
get_jump_snd (a,b,c) = b

-- stateSearch
--
-- This function takes the Board state and finds the best next move for the
-- player, given the game state and constraints provided as input. These
-- constraints include: the state of the current board, the game's board state
-- history, the grid, the list of possible slides and jumps, the current player
-- and the dimension of the board. If there is no next best move since the game
-- has already ended, then this function just returns the current board.
--
-- Usage:
--  stateSearch board history grid slides jumps player depth dimension
--
-- Return:
--  board if the game is over
--  otherwise it returns the best board to move
--

stateSearch :: Board -> [Board] -> Grid -> [Slide] -> [Jump] -> Piece -> Int -> Int -> Board
stateSearch board history grid slides jumps player depth num = -- To Be Completed
   -- If the game is over, then there's no point in searching for the next best
   -- move. In that case, just return the current board
   if (gameOver board history num)
       then board
       -- generate all the possible moves from this board state up to the given
       -- depth. We then apply the minimax algorithm to it, given the heuristic
       -- to find the next best move
       else minimax boardTree heuristic
           where   boardTree = (generateTree board history grid slides jumps player depth num)
                   heuristic = boardEvaluator player history num

--
-- generateTree
--
-- This function generates the search tree of all possible moves from the Board
-- up to the given depth. This function takes the current board and the
-- associated game's board history, the game's grid, the list of possible
-- slides and jumps, the current player's turn (W or B), the search tree depth,
-- and the dimension of the board.
--
-- Usage:
--  generateTree board history grid slides jumps player depth dimension
--
-- Return:
--  the BoardTree of all possible moves up to the given depth
--

generateTree :: Board -> [Board] -> Grid -> [Slide] -> [Jump] -> Piece -> Int -> Int -> BoardTree
generateTree board history grid slides jumps player depth n = -- To Be Completed
    -- base case:
    -- if the board is game over
    -- or it has reached the depth.
    -- The root node has a depth of 0
    -- then just return empty list for children
    if ((gameOver board history n) || depth == 0)
        then (Node depth board [])
        else (
            Node depth board
            -- generate the next state given this state and map those to a
            -- TreeBoard.
            -- The next TreeBoard state needs the updated state info for the
            -- tree
            -- * Board is added to the front of the history
            -- * board structure (grid/slides/jumps/n) are constant
            -- * This player's turn ends and moves to the next
            -- * depth is decremented
            (map (\x -> generateTree x (board:history) grid slides jumps (nextPlayer player) (depth-1) n)
            (generateNewStates board history grid slides jumps player)))

-- This is a helper function which returns the Piece whose turn comes after the
-- given player
-- Precondition: input is either W or B
nextPlayer :: Piece -> Piece
nextPlayer piece =
    if (piece == W) then B else W

--
-- generateNewStates
--
-- This function consumes the arguments described below, it first generates a
-- list of valid moves, applies those moves to the current board to generate
-- a list of next boards, and then checks whether or not that move would
-- have been possible by filtering out those boards already seen before
--
-- Arguments:
-- -- board: a Board representing the most recent board
-- -- history: a list of Boards of representing all boards already seen
-- -- grid: the Grid representing the coordinate-grid the game being played
-- -- slides: the list of all Slides possible for the given grid
-- -- jumps: the list of all Jumps possible for the given grid
-- -- player: W or B representing the player the program is
--
-- Returns: the list of next boards
--

---------completed----------
generateNewStates :: Board -> [Board] -> Grid -> [Slide] -> [Jump] -> Piece -> [Board]
generateNewStates board history grid slides jumps player =
 (statesToBoards (generateNewStates_helper state state_history moves player))
 where
 state = boardToState board grid
 state_history = boardsToStates history grid
 moves = moveGenerator state slides jumps player

-- combine grid and board to produce a state
boardToState :: Board -> Grid -> State
boardToState board grid
 | board == [] = []
 | otherwise = ((head board), (head grid)):(boardToState (tail board) (tail grid))

-- given a list of boards and a grid, convert to a list of states
boardsToStates :: [Board] -> Grid -> [State]
boardsToStates boards grid
 | boards == [] = []
 | otherwise = (boardToState (head boards) grid):(boardsToStates (tail boards) grid)

-- convert a state to the form of a board
stateToBoard :: State -> Board
stateToBoard state
 | state == [] = []
 | otherwise = (fst (head state)):(stateToBoard (tail state))

-- convert a list of states to a list of boards
statesToBoards :: [State] -> [Board]
statesToBoards states
 | states == [] = []
 | otherwise = (stateToBoard (head states)):(statesToBoards (tail states))


-- it is the same as generateNewStates, but instead of consuming slides and jumps
-- it takes in a list of moves which are already generated in generateNewStates.
generateNewStates_helper :: State -> [State] -> [Move] -> Piece -> [State]
generateNewStates_helper state history [] player = []
generateNewStates_helper state history moves player =
 if (elem (generateNewStateForOneMove state (head moves) player) history)
  then (generateNewStates_helper state history (tail moves) player)
  else (generateNewStateForOneMove state (head moves) player):
       (generateNewStates_helper state history (tail moves) player)

-- generate a new board state in accordance with a move.
generateNewStateForOneMove :: State -> Move -> Piece -> State
generateNewStateForOneMove state move player =
 changeStateTo (changeStateFrom state move) move player

-- given a board and a move, change the state of the corresponding tile to
-- empty meaning that a piece has moved out from that tile.
changeStateFrom :: State -> Move -> State
changeStateFrom [] move = []
changeStateFrom state move =
 if ((fst move) == (snd (head state)))
  then (removePiece (head state)):(tail state)
  else (head state):(changeStateFrom (tail state) move)

-- given a board and a move, add a player piece to the correspeonding tile,
-- meaning that the piece has moved to that tile.
changeStateTo :: State -> Move -> Piece -> State
changeStateTo [] move player = []
changeStateTo state move player =
 if ((snd move) == (snd (head state)))
  then ((addPiece (head state) player):(tail state))
  else (head state):(changeStateTo (tail state) move player)

-- remove a piece from the input tile.
removePiece :: Tile -> Tile
removePiece (piece, point) = (D, point)

-- add a player peice to the input tile.
addPiece :: Tile -> Piece -> Tile
addPiece (piece, point) player = (player, point)

--
-- moveGenerator
--
-- This function consumes a state, a list of possible jumps,
-- a list of possible slides and a player from whose perspective
-- to generate moves, to check which of these jumps and slides
-- the player could actually make, and produces a list of valid moves
--
-- Arguments:
-- -- state: a State representing the most recent state
-- -- slides: the list of all Slides possible for the given grid
-- -- jumps: the list of all Jumps possible for the given grid
-- -- player: W or B representing the player the program is
--
-- Note: This is the only instance where the program makes use of the
--		 type State, for our purposes it is zipping the board and the
--		 grid together for making it easier to make moves.
--
-- Note:
-- -- oP is opponentsPieces
-- -- pP is playersPieces
-- -- vS is validSlides
-- -- vJ is validJumps
--
-- Returns: the list of all valid moves that the player could make
--

---------completed----------
moveGenerator :: State -> [Slide] -> [Jump] -> Piece -> [Move]
moveGenerator state slides jumps player =
 moveGenerator_helper state state slides jumps player

-- a helper function to moveGenerator, in which it generates a list of all
-- the moves, both slides and jumps, for the input player.
moveGenerator_helper:: State -> State -> [Slide] -> [Jump] -> Piece -> [Move]
moveGenerator_helper static_state state slides jumps player
 | state == [] = []
 | (fst cur_tile) == player =
    (vSforOnePiece slides (snd cur_tile) static_state) ++
    (vJforOnePiece jumps (snd cur_tile) static_state player) ++
    (moveGenerator_helper static_state (tail state) slides jumps player)
 | otherwise = moveGenerator_helper static_state (tail state) slides jumps player
 where
  cur_tile = (head state)

-- produces all the valid slides for a piece on the board given the state
-- of the board.
vSforOnePiece :: [Slide] -> Point -> State -> [Move]
vSforOnePiece slides point state
 | slides == [] = []
 | ((fst (head slides)) == point) && (check_moveTo_empty (snd (head slides)) state) =
    (head slides):(vSforOnePiece (tail slides) point state)
 | otherwise = vSforOnePiece (tail slides) point state

-- produces all the valid jumps for a piece on the board given the state
-- of the board.
vJforOnePiece :: [Jump] -> Point -> State -> Piece -> [Move]
vJforOnePiece jumps point state player
 | jumps == [] = []
 | ((get_jump_fst (head jumps)) == point) &&
   (check_moveTo_EmptyorOppPiece (get_jump_thd (head jumps)) state player) &&
   (check_middlePiece_Equal (get_jump_snd (head jumps)) state player) =
    (jumpToMove (head jumps)):(vJforOnePiece (tail jumps) point state player)
 | otherwise = vJforOnePiece (tail jumps) point state player

-- convert jump to move
jumpToMove :: Jump -> Move
jumpToMove jump = (get_jump_fst jump, get_jump_thd jump)

-- check the point where a peice is moving to is empty
check_moveTo_empty:: Point -> State -> Bool
check_moveTo_empty point state
 | state == [] = False
 | point == (snd (head state)) =
    if ((fst (head state)) == D)
     then True
     else False
 | otherwise = check_moveTo_empty point (tail state)

-- check the point where a peice is moving to is empty or is an opponent's peice
check_moveTo_EmptyorOppPiece:: Point -> State -> Piece -> Bool
check_moveTo_EmptyorOppPiece point state player
 | state == [] = False
 | point == (snd (head state)) =
    if not ((fst (head state)) == player)
     then True
     else False
 | otherwise = check_moveTo_EmptyorOppPiece point (tail state) player

-- check there is a piece in the middle for a piece to jump over
check_middlePiece_Equal :: Point -> State -> Piece -> Bool
check_middlePiece_Equal point state player
 | state == [] = False
 | point == (snd (head state)) =
    if (fst (head state)) == player
     then True
     else False
 | otherwise = check_middlePiece_Equal point (tail state) player


--
-- boardEvaluator
--
-- Usage: boardEvaluator player history n board myTurn
-- Before: player is the player the program represents, W or B (of type Piece)
--         history is a list of "Board"'s that have already appeared in the game
--         n is the dimension fo the board, of type Int
--         board is the current Board (of type Board)
--         myTurn is a Bool, true if it is the player's turn, false otherwise
-- Returns: an Int representing how good the current board is for the player.
--          High numbers are good for the player.

boardEvaluator :: Piece -> [Board] -> Int -> Board -> Bool -> Int
boardEvaluator player history n board myTurn
  -- game is over and its our turn => we lost
  | gameOver board history n && myTurn  = -10
  -- game is over and its not our turn => we won
  | gameOver board history n            = 10
  -- game not over, count pieces of each player
  | otherwise                           = playerPieces - otherPlayerPieces
  where
    playerPieces = countPiece board player
    otherPlayerPieces = countPiece board otherPlayer
    otherPlayer = if player == W then B else W

--
-- minimax
--
-- Usage: minimax boardTree heuristic
-- Before: boardTree is a BoardTree representing all the possible boards the game
--         could go to in the next n plays where n is the number of moves we allow the
--         the program to look forward to. This n is also the height of the boardTree.
--         heuristic is a partially applied boardEvaluator function. The board and myTurn
--         arguments are missing.
-- Returns: the best board for us to go to in the next play.

minimax :: BoardTree -> (Board -> Bool -> Int) -> Board
minimax (Node _ b children) heuristic =
  -- return the board of the children with the maximum board evaluator value
  board (children!!index)
  where
    -- index of best next board
    index = head [x | x <- [0..(length minimaxList) - 1], minimaxList!!x == maxChild]
    -- max board evaluator value
    maxChild = maximum minimaxList
    -- list of board evaluator values returned from the minimax' helper
    minimaxList = map partialMinimax' children
    partialMinimax' = (\x -> minimax' x heuristic False)

--
-- minimax'
--
-- Usage: minimax' boardTree heuristic maxPlayer
-- Before: boardTree is a BoardTree representing the current branch of the BoardTree in
--         minimax we are looking at. If depth boardTree is 0 then we are at a leaf and
--         then we calculate the heuristic.
--         heuristic is a partially applied boardEvaluator function. The board and myTurn
--         arguments are missing.
--         maxPlayer is a Bool representing whether it is the programs turn to do at the current
--         level of the BoardTree from minimax. Indicates whether to maximize or minimize.
-- Returns: an Int representing the minimax value at the top of the tree.

minimax' :: BoardTree -> (Board -> Bool -> Int) -> Bool -> Int
minimax' boardTree heuristic maxPlayer
  -- not at the bottom and maxPlayer is playing, take maximum of nextBoards
  | depthCheck && emptyListCheck && maxPlayer = maximum (map partialMinimax' (nextBoards boardTree))
  -- not at the bottom and maxPlayer is not playing, take minimum of nextBoards
  | depthCheck && emptyListCheck              = minimum (map partialMinimax' (nextBoards boardTree))
  -- at the bottom, evaluate board
  | otherwise                                 = heuristic (board boardTree) maxPlayer
  where
    depthCheck = depth boardTree /= 0
    emptyListCheck = not (null (nextBoards boardTree))
    partialMinimax' = (\x -> minimax' x heuristic (not maxPlayer))

