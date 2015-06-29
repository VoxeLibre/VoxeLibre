--Para ser usado no gerador aleatório.
domb.aleatorio = nil

--Inicialização da variável aleatoria para que seja usada quando necessário.
minetest.after(0.01, function()
  domb.aleatorio=PseudoRandom(200 + (minetest.env:get_timeofday()*100000))
end)

-- Identifica vizinhança de um ponto, os pontos retornados tem a parte superior como ponto 1.
-- Totaliza atualmente água, lava e ar.  Contabiliza totais e separando fontes de fluindo.

function DOM_vizinhos(ponto)
  local p = {}
  local vx=0
  local vy=0
  local vz=0
  local tipo = ''
  local pontos = 0
--  p.total = 0
  p.total_ar = 0
  p.total_lava = 0
  p.total_lava_fonte = 0
  p.total_agua = 0
  p.total_agua_fonte = 0
  p.n = {'','','','','',''}

  --Começa pelo y (altura) de baixo para cima, sendo assim os 3 últimos testes serão os 
  for vy=-1,1 do
    for vx=-1, 1 do
      for vz=-1,1 do
        p.n[pontos] = ''
        tipo =  minetest.env:get_node({x=(ponto.x + vx), y=(ponto.y + vy), z=(ponto.z + vz)}).name
--print("Ponto pego: " .. tipo)
        -- Busca pontos onde dois eixos estejam zerados e um outro tenha valor.
        if vx==0 and vy==0 and vz==0 then
          -- Ignora caso seja exatamente o ponto testado. 
        elseif (vx==0 and vy==0 and vz~= 0) or (vx==0 and vz==0 and vy~=0) or (vy==0 and vz==0 and vx~=0) then
--print("Ponto: " .. tostring(vx) .. " " .. tostring(vy) .. " " .. tostring(vz) .. " (Pontos: " .. tostring(pontos) .. ")")
--print("Tipo: " .. tipo)
          if tipo == "default:air" or tipo == "air" then
            p.total_ar = p.total_ar + 1
--print("Ar contado, total de " .. tostring(p.total_ar))
          elseif tipo == "default:water_source" or tipo == "default:water_flowing" or tipo == "default:water" then
            p.total_agua = p.total_agua + 1
--print("Agua contada, total de " .. tostring(p.total_agua) .. ", tipo:" .. tipo)
            if tipo == "default:water_source" then
              p.total_agua_fonte = p.total_agua_fonte + 1
            end
          elseif tipo == "default:lava_source" or tipo == "default:lava_flowing" then
            p.total_lava = p.total_lava + 1
            if tipo == "default:lava_source" then
              p.total_lava_fonte = p.total_lava_fonte + 1
            end
          end

          p.n[pontos] = tipo
          pontos = pontos + 1
--if(vx==0 and vz==0 and vy==-1) then
--print("Ponto n para x=0, y=-1 e z=0 é o : " .. tostring(pontos))
--end
        end
      end
    end
  end 

  p.total_lava_corrente = p.total_lava - p.total_lava_fonte
  p.total_agua_corrente = p.total_agua - p.total_agua_fonte

--  print("Retornando total ar de :" .. tostring(p.total_ar))
  return(p)
end


--[[
  Rotina que pega o texto e remove eventuais símbolos não desejados.
]]--

function DOM_remove_simbolos(texto)
  local t = ""
  
  if texto == "" or texto == nil then
    return("")
  end

  -- Remoção de símbolos proibidos.
  t=string.gsub(texto, "(%[)", "")
  t=string.gsub(t, "(%])", "")
  t=string.gsub(t, "(%()", "")
  t=string.gsub(t, "(%))", "")
  t=string.gsub(t, "(#)", "")
  t=string.gsub(t, "(@)", "")
  t=string.gsub(t, "(?)", "")
  t=string.gsub(t, "(!)", "")
  t=string.gsub(t, "($)", "")
  t=string.gsub(t, "(%%)", "")
  t=string.gsub(t, "(&)", "")
  t=string.gsub(t, "(*)", "")
  t=string.gsub(t, "(=)", "")

  return(t)
end

--[[
  Rotina que pega o texto e remove eventuais espaços no inicio, no final e espacos duplos no meio da string.
]]--

function DOM_remove_espacos(texto)
  local t = ""
  
  if texto == "" or texto == nil then
    return("")
  end
  t = texto

  --Remove todos os espaços duplos que encontrar.
  while string.find(t,"  ") do
    t=string.gsub(texto, "(  )", " ")
  end

  --Remove espaços no final e no início do texto.
  t=string.trim(t)
    
  return t
end


--[[
  Rotina usada para inspecionar elementos retornando um relatório na linha de comando.
  Aceita quantidade variável de parâmetros sendo:
  1) Arquivo
  2) Linha
  3) Teste
  4) Parâmetros
 
]]--
function DOM_inspeciona_condicional(...)
  if(arg[3] ~= true) then return end

  local a=0
  local linha= {tostring(debug.getinfo(2, 'l').currentline)}
  local arquivo = debug.getinfo(2, 'S').short_src or debug.getinfo(2,'S').source
  if string.len(arquivo) > 25 then
    arquivo = "..." arquivo:sub(string.len(arquivo)- 22) 
  end

  if arg[2] ~= nil then
    linha = arg[2]
  end

  if arg[1] ~= nil then
    arquivo = arg[1]
  end



  print("====================================== [DOM Inspeciona] =======")
  print(arquivo .. "  [" .. linha .. "]")
  print(tostring(arg[4]))
  print("---------------------------------------------------------------")
  for a=5,#arg,1 do
    print(string.format("%s", dump(arg[a])))
  end
  print("");
  print("-------------------------------------- [DOM Inspeciona] ---Fim-")
  print(arquivo .. "  [" .. linha .. "]")
  print("===============================================================")
end

--[[
  Chama a rotina de inpecao sem a necessidade de passar a condicao.
]]--

function DOM_inspeciona(...)
  local linha = debug.getinfo(2, 'l').currentline
  local arquivo = debug.getinfo(2, 'S').short_src or debug.getinfo(2,'S').source
  if string.len(arquivo) > 25 then
    arquivo = "..." .. arquivo:sub(arquivo:len(arquivo)- 22) 
  end

  DOM_inspeciona_condicional(arquivo,linha,true,...)
end

--[[
  Inspeção simplificada que não necessita de valores adicionais, apenas o titulo.  Mostra a linha
--]]
function DOM_inspeciona_r(titulo)
  if titulo == nil then
    titulo = ""
  end

  local linha = debug.getinfo(2, 'l').currentline
  local arquivo = debug.getinfo(2, 'S').short_src or debug.getinfo(2,'S').source
  if string.len(arquivo) > 25 then
    arquivo = "..." arquivo:sub(string.len(arquivo)- 22) 
  end

  print(arquivo .. " [" .. linha .. "] " .. titulo)
end


--[[
  Realiza a união do string.format com o print simulando o printf do C++.
--]]
function DOM_print(...)
  print(string.format(...))
end

--[[
  Permite envio de mensagens para o log no minitest ao invés do terminal, segue a formatação do string.format
--]]
function DOM_log(...)
  -- action, error, info
  minetest.log("action", "[DOM]"..string.format(...))
end


--[[
  Centraliza os valores na matriz 5x5 de acordo com a largura e altura recebidas gerando automaticamente uma margem ao redor da fórmula.
--]]
function DOM_centraliza_matriz_5x5(matriz, largura, altura)
  --Centraliza se largura ou altura forem menores que 5.
  --Largura ou Altura/Critério:  5/Ignora, 4/Ignora, 3/1 de margem, 2/1 de margem, 1/2 de margem
local i = 0
a=matriz[1][3]
if a~=nil then 
  if string.find(a,"gravel") then 
    i = 1
  end
end
--DOM_inspeciona("Rotina centraliza matriz: ",matriz)

  local margem_superior = math.floor((5-altura)/2)
  local margem_lateral  = math.floor((5-largura)/2)
  local d_a = margem_lateral
  local d_b = margem_superior

  if margem_superior > 0 or margem_lateral > 0 then 
    for a=5,margem_lateral+1,-1 do --Colunas
      for b=5,margem_superior+1,-1 do --Linhas
        -- Transfere valor da posição original para a deslocada tornando o valor da posição original como nulo.
        matriz[a][b] = matriz[a-d_a][b-d_b]
        matriz[a-d_a][b-d_b] = nil
      end
    end
  end
--DOM_inspeciona("Matriz convertida:",matriz)

---DOM_inspeciona("Saida da rotina centraliza matriz: ",matriz)
  return matriz
end

--[[
  Cria matriz 5x5 a patir de uma linha de itens separados por virgulas
  - Ignora itens a partir do sexto...
--]]
function DOM_cria_matriz_5x5(itens)
  local m_5x5={{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil}},{{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil}},{{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil}},{{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil}},{{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil},{nil,nil,nil,nil,nil}}
  local i = {}
  local a = 0
  local largura = 0
  
  if itens ~= "" and itens ~= nil then
    if itens.find(itens,",") then
    else
      table.insert(i,itens)
      a = a + 1
    end
  end

  while string.find(itens,",") do
    lido = string.sub(itens,1,itens.find(","))
    itens = string.sub(itens,itens.find(",")+1)
    table.insert(i,lido)
    a = a + 1
  end

  largura = a 
  while a < 5 do
    table.insert(i,nil)
    a = a + 1
  end
  
  for a=1,5,1 do --Colunas
  -- Transfere valores para a linha 3.
     m_5x5[3][a] = i[a]
  end

  m_5x5 = DOM_centraliza_matriz_5x5(m_5x5,largura,5)

  return m_5x5
end

--[[
  Converte valor posicional xyz para valor em texto separados por virgulas e sem espaços:
  <classe> -> "x,y,z"
]]--
function DOM_de_xyz_para_texto(valor)
  if valor==nil then
    return "0,0,0"
  end

  local r = ""
  r = tostring(valor.x)..",".. tostring(valor.y) ..",".. tostring(valor.z)
  return r
end


--[[
  Converte valor posicional de texto para a classe xyz:
  "x,y,z" -> <classe>


  Convert values x,y,z in text to the class xyz:
  "x,y,z" -> <classe>
]]--
function DOM_de_texto_para_xyz(valor)
  if valor==nil or recebido == "" then
    return {x=0,y=0,z=0}
  end

--print("Recebido:".. dump(valor))
  local r={x=0,y=0,z=0}
  local d=valor
  r.x=tonumber(d:sub(1,string.find(d,",")-1))

  d=d:sub(string.find(d,",")+1)
  r.y= tonumber(d:sub(1,string.find(d,",")-1))

  d=d:sub(string.find(d,",")+1)
  r.z= tonumber(d)
--print("Retorno:".. dump(r))
  return r
end


--[[
  Mensagem básica de carga
  Recebe:
    nome do modulo, caminho do modulo

  Basic load message
  Params:
    module name, path of the module
]]--
function DOM_mb(m,c)
--  minetest.log("action", "[DOM]"..m.." loaded from "..minetest.get_modpath(minetest.get_current_modname()))
  minetest.log("action", "[DOM]"..m.." is ready.")
end



--[[
  Registra comando para chamar rotinas de apoio pelo chat com o comando /dom_util <comando> <parametros...>
  Comandos:
  apaga x y z 	Apaga node no lugar especificado.
    
    if  comando == "comando" then -- Comando?
      minetest.chat_send_player(name, "[DOM]dom_util: ".."Comando?")
    elseif comando == "comando2" then -- Comando?
      minetest.chat_send_player(name, "[DOM]dom_util: ".."Comando2?")
    end
  end

--]]
function DOM_registra_comandos_de_uso_geral()
end

--[[
  Quebra texto em lista utilizando espaços como delimitadores.
--]]
function DOM_quebra_texto_em_lista (texto)
  local lista = {}

  lista = DOM_quebra_texto_em_lista_por_delimitador (texto, " ")

  return lista
end

--[[
  Quebra texto em lista utilizando delimitador pedido.
--]]
function DOM_quebra_texto_em_lista_por_delimitador (texto, delimitador)
  local lista = {}
  lista.tamanho = 0
  local t = ""
  local fatia = ""
  
  if texto==nil or texto =="" then return nil end -- Caso texto recebido não seja válido retorna nulo
  if delimitador==nil or delimitador =="" then return nil end -- Caso delimitador recebido não seja válido retorna nulo

--print("Texto: \'"..dump(texto).."\'")
  t = texto 
  if not t:find(delimitador) then  -- Cria lista com um item caso não seja encontrado nenhum delimitador.
    table.insert(lista, t)
    lista.tamanho = 1
  end
 
  while t:find(delimitador) do -- Enquanto o delimitador puder ser encontrado no texto, fica no laço.
    fatia = t:sub(1,t:find(delimitador)-1)
    table.insert(lista,fatia)
    lista.tamanho= lista.tamanho + 1

    t = t:sub(t:find(delimitador)+1)

    if not t:find(delimitador) then -- Adiciona o item que sobra ao final após o último delimitador ser removido.
      table.insert(lista,t)
      lista.tamanho= lista.tamanho + 1
    end
  end

--print("saída: "..dump(table.tamanho).." => "..dump(table))
  return lista
end

--[[
  Copia ponto evitando que seja passada matriz por referência
--]]
function DOM_copia_ponto(origem,destino)
--DOM_inspeciona("Copia ponto:",origem,destino)
  if destino == nil then
    destino = {}
  end

  destino.x = tonumber(origem.x)
  destino.y = tonumber(origem.y)
  destino.z = tonumber(origem.z)

  return destino
end

-- Pega valores meta de um item, provavelmente se aplica a nodos.
function DOM_get_item_meta (item)
  local r = {}
  local v = item["metadata"]

  if v==nil then
    return r
  end

  if string.find(v,"return {") then
    r = minetest.deserialize(v)
  end

  return r
end

-- Associa valores meta a um item, provavelmente se aplica a nodos.
function DOM_set_item_meta(i, v)
  local t = minetest.serialize(v)

  i["metadata"]=t
end
