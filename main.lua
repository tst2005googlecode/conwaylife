local gameOfLife =  require "gameOfLife"

local filename="E:\\software\\misc\\jslife\\c2-extended\\c2-0002.lif"
local universeSize = 300
local conwayGrid = gameOfLife.getConwayGrid(filename, universeSize)
local universeSize = #conwayGrid 

function love.load()
  love.graphics.setColor(105,105,105,255)
  love.graphics.setBackgroundColor(255,255,255)
end


function love.update(dt)
  conwayGrid = gameOfLife.getNextGeneration(conwayGrid)
end

function love.draw()
  local size = 5; style=""
  for i=1,universeSize do
    for j= 1,universeSize do
      if conwayGrid[i][j]~=nil then
        style="fill"
      else
        style="line"
      end
      love.graphics.rectangle(style, j*size, i*size, size, size)
    end
  end  
  
  love.timer.sleep(100)
end