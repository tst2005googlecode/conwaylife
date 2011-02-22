local gameOfLife = {}

function gameOfLife.getFileText(filename)  
  io.input(filename)
  text = io.read("*all")
  return text
end

--Get the lines from RLE format
function gameOfLife.getLinesRLE(text)
  local lines = {}
  local i=1
  local linePattern = "[^\n]*" --everything before an end-of-line character : \n
  local commentPattern = "#.*" --all lines
  for line in string.gmatch(text, linePattern) do
    if line~=nil and line~="" then
  	  local isComment = nil~=string.match(line, commentPattern)
  	  if isComment==false then --skip comments
  	    --print(i .." ".. line)
  	    lines[i]=line
  	    i=i+1
  	  end
    end
  end
  return lines
end

--Get the number of rows and columns
function gameOfLife.getRowsColumns(lines)
  local info = lines[1]
  --print(info)
  specs = {}
  local j=1

  local keyValuePattern = "%w+%s*=%s*(%w+)" -- word(key) + spaces + '=' + word (value that we need)
  for v in string.gmatch(info, keyValuePattern) do
   specs[j]=v
    --print(specs[j])
    j=j+1
  end

  local columns = specs[1]; rows=specs[2];
  --print("x="..x..",y="..y)

  return tonumber(rows), tonumber(columns)
end

--Get the Conway Pattern in a matrix
function gameOfLife.getConwayPattern(rows, columns, lines)
  local conwayPattern = ""
  for i=2,#lines do
    conwayPattern = conwayPattern..lines[i] 
  end
  --print(conwayPattern)

  patternGrid = {}          -- create the matrix
  for i=1,rows do
    patternGrid[i] = {}
    for j=1,columns do
      patternGrid[i][j] = nil
    end
  end

  local row = 1
  local column = 1
  local char = ""
  local i=1;
  while string.sub(conwayPattern,i,i)~="" do
    char = string.sub(conwayPattern,i,i)
    local n = tonumber(char) 
    if n~=nil then
      i=i+1 --repeated char location
      char = string.sub(conwayPattern,i,i)      
      for j=1,n do
        if char=="o" then -- live cell
          patternGrid[row][column] = char
          io.write(patternGrid[row][column].." ")
        else --skip "b"
          patternGrid[row][column] = nil                      
        end
        column = column+1
      end
    elseif char =="$" then --end of row
      row = row+1
  	  column = 1
      print(" ")
    elseif char =="!" then --end of pattern
  	  break
    elseif char=="o" then -- live cell
      patternGrid[row][column] = char
      io.write(patternGrid[row][column])
      column = column+1
    else --skip "b"
      column = column+1
    end
    i=i+1 --next char  
  end
  
  return patternGrid
end


function gameOfLife.getConwayGrid(filename, universeSize)  
  local text = gameOfLife.getFileText(filename)
  local lines = gameOfLife.getLinesRLE(text)
  local rows, columns, conwaypattern = gameOfLife.getRowsColumns(lines)
  local conwayPatternGrid = gameOfLife.getConwayPattern(rows, columns, lines)

  --setup the universe grid    
  universeGrid = {}          -- create the matrix
  for i=1,universeSize do
    universeGrid[i] = {}
    for j=1,universeSize do
      universeGrid[i][j] = nil
    end
  end
  
  --populate the universe grid  
  local rowOffset = math.floor((universeSize-rows)/4)
  local columnOffset = math.floor((universeSize-columns)/4)
  --print(universeSize.."-"..rowOffset.."-"..columnOffset.."-"..rows.."-"..columns)

  for i=1,rows do
    for j=1,columns do
      universeGrid[i+rowOffset][j+columnOffset] = conwayPatternGrid[i][j]
    end
  end  
  return universeGrid
end

function gameOfLife.getNextGeneration(universeGrid)
  local universeSize=#universeGrid
  
  local nextGenGrid = {}
  for i=1,universeSize do
   nextGenGrid[i]={}
    for j=1,universeSize do
      nextGenGrid[i][j] = universeGrid[i][j]
    end
  end  
  
  
  local liveNeighbors = 0
  
  for i=2,universeSize-1 do
    for j= 2,universeSize-1 do
      liveNeighbors = gameOfLife.getLiveNeighbors(i, j, universeGrid)
      if universeGrid[i][j]~=nil then        
        if liveNeighbors~=2 and liveNeighbors~=3 then
          nextGenGrid[i][j]=nil
        end
      else
        if liveNeighbors==3 then
          nextGenGrid[i][j]="o"
        end
      end         
    end
  end
  
  return nextGenGrid
end

function gameOfLife.getLiveNeighbors(i, j, universeGrid)
  local liveNeighbors = 0;
  if universeGrid[i-1][j-1]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  if universeGrid[i-1][j]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  if universeGrid[i-1][j+1]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  if universeGrid[i][j-1]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  if universeGrid[i][j+1]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  if universeGrid[i+1][j-1]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  if universeGrid[i+1][j]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  if universeGrid[i+1][j+1]~=nil then
    liveNeighbors=liveNeighbors+1
  end
  
  return liveNeighbors
end

return gameOfLife