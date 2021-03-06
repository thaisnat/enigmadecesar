{-
    ENIGMA DE CESAR
    APLICACOES DE PARADIGMAS DE LINGUAGEM DE PROGRAMACAO - 2017.2 - UFCG
    EQUIPE: ALICE FERNANDES
            ITALO MENEZES
            IVYNA ALVES
            THAIS TOSCANO
            VALTER LUCENA

-}

-- imports
import System.Random
import Charadas
import Textos
import Data.Char
import Palavras
import System.Exit

-- constantes --
listaCharadas = Charadas.charadas
listaFacil = Palavras.facil
listaMedio = Palavras.medio
listaDificil = Palavras.dificil
limiteChave = 4


-- funcao principal
main = do
    Textos.telaInicial
    Textos.desenhaEsfinge
    putStrLn $ "Pressione 1 para as regras, 2 para jogar agora!"
    entrada <- getLine
    let opcao = read entrada :: Int
    if opcao == 1
        then do
            Textos.regras
            putStrLn $ "Digite 2 para jogar agora, ou 0 para sair"
            novaEntrada <- getLine
            let novaOpcao = read novaEntrada :: Int
            if novaOpcao == 2
                then jogar
            else if novaOpcao == 0
                then (exitWith ExitSuccess)
            else do
                putStrLn "Voce nao leu direito direito as instrucoes. Reinicie o jogo!"
                exitWith ExitSuccess
    else if opcao == 2
        then jogar
    else do
        putStrLn "Voce nao leu direito direito as instrucoes. Reinicie o jogo!"
        exitWith ExitSuccess

-- funcao jogar
jogar = do
    let nivel = 1
    mostraCharada nivel

-- funcao que mostra a charada criptografada para o usuario e recebe a resposta
mostraCharada nivel = do
    if nivel > 3 then return ()
    else do
        indexCharada <- geraIndice 0 (length listaCharadas - 1)
        chave <- geraIndice 1 limiteChave

        let charada = fst (listaCharadas !! indexCharada)
        let resposta = snd (listaCharadas !! indexCharada)
        let cifrada = cifra charada chave

        putStrLn $ "\n"
        putStrLn $ "Nivel: " ++ show nivel
        putStrLn $ "\n" ++ cifrada
        putStrLn $ "\n" ++ "Decifre as palavras abaixo:"

        let cont = 0
        let contPedaco = 0
        escolhePalavra cont cifrada chave contPedaco nivel

        putStrLn $ "Resposta: "

        respostaUsuario <- getLine
        let resultado = respostaUsuario == resposta
        if resultado
            then mostraCharada (nivel+1)
        else do
            putStrLn $ "Você perdeu :/"
            putStrLn $ "Pressione 2 para jogar novamente ou 0 para sair:"
            opcao <- readLn
            if opcao == 2 then jogar else (exitWith ExitSuccess)

--funcao que exibe as palavras usadas para descriptografar a charada
escolhePalavra cont charada chaveCharada contPedaco nivel = do
     if cont == 3 then return ()
     else do
         let palavras = selecionaLista nivel :: [String]

         indexPalavra <- geraIndice 0 (length palavras - 1)
         chave <- geraIndice 1 limiteChave

         let palavra = palavras !! indexPalavra
         let palavraCifrada = cifra palavra chave

         putStrLn $ show (cont+1) ++ ")" ++ palavraCifrada
         putStrLn $ "Dica: chave = " ++ show chave
         putStrLn $ "Resposta: "

         respostaUsuario <- getLine

         if respostaUsuario == palavra then do
             let pedaco = (contPedaco+1) * terco where terco = (length charada `div` 3)
             let string = decifraPedaco charada chaveCharada 0 pedaco ++ drop (pedaco+1) charada

             putStrLn string
             escolhePalavra (cont + 1) charada chaveCharada (contPedaco+1) nivel
         else do
             putStrLn $ "Você perdeu :/"
             putStrLn $ "Pressione 2 para jogar novamente ou 0 para sair:"

             opcao <- readLn
             if opcao == 2 then jogar else (exitWith ExitSuccess)

-- funcao que seleciona onde buscar as palavras de acordo com o nivel
selecionaLista :: Int -> [String]
selecionaLista nivel
    | nivel == 1 = listaFacil
    | nivel == 2 = listaMedio
    | nivel == 3 = listaDificil

-- funcao que gera um indice aleatorio
geraIndice :: Int -> Int -> IO Int
geraIndice inicio limite = randomRIO(inicio, limite)

-- funcoes para nao deixar que os caracteres saiam do escopo [a..z]
letraPNum :: Char -> Int
letraPNum letra = ord letra - ord 'a'

numPLetra :: Int -> Char
numPLetra num = chr (num + ord 'a')

-- funcao para fazer o descolamento de uma letra
desloca :: Char -> Int -> Char
desloca letra desloc
    | (isAlpha letra) = numPLetra (( letraPNum (toLower letra) + desloc) `mod` 26)
    | otherwise = letra

-- cifra de cesar
cifra :: String -> Int -> String
cifra palavra desloc = [desloca palav desloc | palav <- palavra]

-- funcao que retorna uma parte de uma string
substring :: String -> Int -> Int -> String
substring palavra inicio fim = take (fim-inicio+1) (drop (inicio) palavra)

-- funcao que decifra apenas uma parte de uma string
decifraPedaco :: String -> Int -> Int -> Int -> String
decifraPedaco palavra chave inicio fim = cifra (substring palavra inicio fim) (0-chave)
