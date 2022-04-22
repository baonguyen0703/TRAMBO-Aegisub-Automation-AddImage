script_name="@TRAMBO: Add Image"
script_description="Add images / Replace main, second (karaoke), border, and shadow colors with images"
script_author="TRAMBO"
script_version="1.0"

--Main 
function main(sub, sel, act)
    sel = open_dialog(sub,sel)
    aegisub.set_undo_point(script_name)
    return sel
end

function open_dialog(sub,sel)
  dialog_config = 
  {
    {
      class = "label",
      x = 0, y = 0, width = 1, height = 1,
      label = "Apply to:"
    },
    {
      class = "checkbox", name = "logo",
      x = 0, y = 1, width = 1, height = 1,
      label = "Image(logo)" ,
      value = false
    },
    {
      class = "checkbox", name = "main",
      x = 1, y = 1, width = 1, height = 1,
      label = "1img" , hint = "main",
      value = false
    },
    {
      class = "checkbox", name = "second",
      x = 2, y = 1, width = 1, height = 1,
      label = "2img" , hint = "for karaoke",
      value = false
    },
    {
      class = "checkbox", name = "bord",
      x = 3, y = 1, width = 1, height = 1,
      label = "3img" , hint = "border",
      value = false
    },
    {
      class = "checkbox", name = "shad",
      x = 4, y = 1, width = 1, height = 1,
      label = "4img", hint = "shadow",
      value = false
    },
    {
      class = "checkbox", name = "all",
      x = 5, y = 1, width = 1, height = 1,
      label = "all",
      value = false
    }
  }

  buttons = {"Add 1 Image","Add Multi Images","Delete",cancel = 'Cancel'}
  
  opt, res = aegisub.dialog.display(dialog_config,buttons)

    if opt == "Add 1 Image" then
      path = open_img()
      if res.all then
        sel = add_img(sub,sel,path,1)
        sel = add_img(sub,sel,path,2)
        sel = add_img(sub,sel,path,3)
        sel = add_img(sub,sel,path,4)
        sel = add_img(sub,sel,path,0)
      else
        if res.main then
          sel = add_img(sub,sel,path,1)
        end
        if res.second then
          sel = add_img(sub,sel,path,2)
        end
        if res.bord then
          sel = add_img(sub,sel,path,3)
        end
        if res.shad then
          sel = add_img(sub,sel,path,4)
        end
        if res.logo then
          sel = add_img(sub,sel,path,0)
        end
      end
      
      -- add different images to each choices
    elseif opt == "Add Multi Images" then
      local pathLogo = ""
      if res.all then
        pathLogo = open_img(0)
        local path = open_img(1)
        sel = add_img(sub,sel,path,1)
        path = open_img(2)
        sel = add_img(sub,sel,path,2)
        path = open_img(3)
        sel = add_img(sub,sel,path,3)
        path = open_img(4)
        sel = add_img(sub,sel,path,4)
        sel = add_img(sub,sel,pathLogo,0)
      else ---
        if res.logo then
          pathLogo = open_img(0)
        end
        if res.main then
          local path = open_img(1)
          sel = add_img(sub,sel,path,1)
        end
        if res.second then
          local path = open_img(2)
          sel = add_img(sub,sel,path,2)
        end
        if res.bord then
          local path = open_img(3)
          sel = add_img(sub,sel,path,3)
        end
        if res.shad then
          local path = open_img(4)
          sel = add_img(sub,sel,path,4)
        end
        if res.logo then
          sel = add_img(sub,sel,pathLogo,0)
        end
      end
      
    elseif opt == "Delete" then
      if res.all then
        sel = delete_img(sub, sel, 1)
        sel = delete_img(sub, sel, 2)
        sel = delete_img(sub, sel, 3)
        sel = delete_img(sub, sel, 4)
        sel = delete_img(sub, sel, 0)
      else
        if res.main then
          sel = delete_img(sub, sel, 1)
        end
        if res.second then
          sel = delete_img(sub, sel, 2)
        end
        if res.bord then
          sel = delete_img(sub, sel, 3)
        end
        if res.shad then
          sel = delete_img(sub, sel, 4)
        end
        if res.logo then
          sel = delete_img(sub, sel, 0)
        end
      end
    end
  return sel
end  

--delete logo lines / img tags
function delete_img(sub, sel, mode)
  local newSel = {}
  local newSub = sub
  local n = 0
  if mode == 0 then
    for si, li in ipairs(sel) do
      local line = sub[li-n]  
      if string.find(line.text,"\\p%d") ~= nil then
        table.insert(newSel, li-n)
        newSub.delete(li-n)
        n = n + 1
      end
    end
    sel = newSel
    sub = newSub
   
  else
    tostring(mode)
    for si, li in ipairs(sel) do
      local line = sub[li]
      if string.find(line.text,"\\p%d") == nil then
        line.text = string.gsub(line.text, "\\" .. mode .. "img(.-%))", "")
        sub[li] = line
      end
    end
  end
  return sel
end

-- add 1 image to multiple line , mode = 0,1,2,3,4
function add_img(sub, sel, path, mode)
  
    if mode == 0 then --logo
      local w, h = getImgSize(path)
      local drawing = draw(w,h)
      path = ass_path(path)
      
      local n = 0
      local newSel = {}
      
      for si, li in ipairs(sel) do
        local line = {}
        line = sub[li+n]
        local pos = ""
        if string.find(line.text,"\\pos%(") ~= nil then
          pos = string.match(line.text,"(\\pos.-%))")
        end
        line.text = "{\\an5\\bord0\\shad0\\p1\\1img(" .. path .. ",0,0)" .. pos .. "} ".. drawing
        sub.insert(li+n, line)
        table.insert(newSel, si, li+n+1)
        table.insert(newSel, si, li+n)
          n = n + 1
      end
      sel = newSel
    else -- mode = 1,2,3,4
      path = ass_path(path)
      tostring(mode)
      for si, li in ipairs(sel) do
        local line = sub[li]
        
        local add = "\\" .. mode .. "img(" .. path .. ",0,0)"
        if string.match(line.text, '{.*}') == nil or line.text == nil then
          line.text = "{" .. add .. "}" .. line.text
        else   
          if string.find(line.text,mode .. "img") == nil then 
            local tags = string.match(line.text, '{(.-)}')
            local new_tags = "{" .. tags .. add .. "}"
            line.text = string.gsub(line.text, "{(.-)}", new_tags,1)
          else
            subpath = "\\" .. mode .. "img(.-%))"
            if string.find(line.text, '\\p%d') == nil then
              line.text = string.gsub(line.text, subpath, add)
            end
          end
        end
      sub[li] = line
      end
      
    end
    return sel
end


function open_img(mode)
  local path
  if mode == 0 then
    path = aegisub.dialog.open("Choose a png image for Image/Logo","","","PNG files (*.png)|*.png", false, true)
  elseif mode == 1 then
    path = aegisub.dialog.open("Choose a png image for 1img","","","PNG files (*.png)|*.png", false, true)
  elseif mode == 2 then
    path = aegisub.dialog.open("Choose a png file for 2img","","","PNG files (*.png)|*.png", false, true)
  elseif mode == 3 then
    path = aegisub.dialog.open("Choose a png file for 3img","","","PNG files (*.png)|*.png", false, true)
  elseif mode == 4 then
    path = aegisub.dialog.open("Choose a png file for 4img","","","PNG files (*.png)|*.png", false, true)
  else
    path = aegisub.dialog.open("Choose a png image","","","PNG files (*.png)|*.png", false, true)
  end
  return path
end

--convert original path to aegisub's legal path
function ass_path(path)
  return string.gsub(path, "(\\)", "/")
end

--draw mask for image/logo
function draw(w,h)
return string.format("m 0 0 l %s 0 %s %s 0 %s", w, w, h, h)
end

--getImgSize function modified and shortened from Get Image Size by: MikuAuahDark
function getImgSize(file)

  file = assert(io.open(file))

	local width,height=0,0
	file:seek("set",1)
	-- Detect if PNG
	if file:read()=="PNG" then
		--[[
			The strategy is
			1. Seek to position 0x10
			2. Get value in big-endian order
		]]
		file:seek("set",16)
		local widthstr,heightstr=file:read(4),file:read(4)
		
    file:close()
		
		width=widthstr:sub(1,1):byte()*16777216+widthstr:sub(2,2):byte()*65536+widthstr:sub(3,3):byte()*256+widthstr:sub(4,4):byte()
		height=heightstr:sub(1,1):byte()*16777216+heightstr:sub(2,2):byte()*65536+heightstr:sub(3,3):byte()*256+heightstr:sub(4,4):byte()
		return width,height
	end
  
	file:seek("set")
	refresh()
end

--send to Aegisub's automation list
aegisub.register_macro(script_name,script_description,main,macro_validation)

