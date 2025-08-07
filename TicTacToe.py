import numpy as np  # Importa a biblioteca NumPy para manipulação eficiente de arrays (usada para o tabuleiro).
import os           # Importa o módulo 'os' para interagir com o sistema operacional (usado para limpar a tela).

def limpar_tela():
    """
    Limpa o console da tela.
    Verifica o sistema operacional para usar o comando correto ('cls' para Windows, 'clear' para outros).
    """
    os.system('cls' if os.name == 'nt' else 'clear')

def print_board(board):
    """
    Imprime o estado atual do tabuleiro do Jogo da Velha no console.
    """
    # Dicionário para mapear os números do tabuleiro para os símbolos visuais (espaço, X, O).
    symbols = {0: ' ', 1: 'X', 2: 'O'}
    print("\n")  # Adiciona uma linha em branco para melhor espaçamento.
    for row in board:
        # Junta os símbolos de cada célula da linha com " | " para formar a representação visual da linha.
        print(" | ".join(symbols[cell] for cell in row))
        print("-" * 9)  # Imprime uma linha horizontal para separar as linhas do tabuleiro.
    print("\n")  # Adiciona uma linha em branco para melhor espaçamento.

def check_winner(board):
    """
    Verifica se há um vencedor no tabuleiro atual.
    Retorna o número do jogador (1 para Humano/X, 2 para IA/O) se houver um vencedor, ou 0 caso contrário.
    """
    for player in [1, 2]:  # Itera para verificar ambos os jogadores.
        # Verifica linhas: se todas as células de uma linha são do mesmo jogador.
        if any(np.all(board[i, :] == player) for i in range(3)) \
           or any(np.all(board[:, i] == player) for i in range(3)) \
           or np.all(np.diag(board) == player) \
           or np.all(np.diag(np.fliplr(board)) == player):
            return player  # Retorna o jogador que venceu.
    return 0  # Nenhum vencedor encontrado.

def is_draw(board):
    """
    Verifica se o jogo terminou em empate.
    Retorna True se todas as células estiverem preenchidas e não houver vencedor, False caso contrário.
    """
    return np.all(board != 0)  # Retorna True se nenhuma célula for 0 (vazia).

def minimax(board, depth, is_maximizing):
    """
    Implementação do algoritmo Minimax para determinar a melhor jogada.
    É uma função recursiva que avalia todos os possíveis estados do jogo.

    Args:
        board (np.array): O estado atual do tabuleiro.
        depth (int): A profundidade atual na árvore de busca (não usada para poda neste exemplo simples).
        is_maximizing (bool): True se a chamada atual for para o jogador que está maximizando (IA),
                              False se for para o jogador que está minimizando (Humano).

    Returns:
        int: O score da jogada: 1 para vitória da IA, -1 para vitória do Humano, 0 para empate.
    """
    winner = check_winner(board)
    if winner == 2:  # Se a IA vence nesta posição, é um score alto para ela.
        return 1
    elif winner == 1:  # Se o Humano vence nesta posição, é um score baixo para a IA.
        return -1
    elif is_draw(board):  # Se for um empate, o score é neutro.
        return 0

    if is_maximizing:  # Vez da IA (maximizar o score)
        best_score = -np.inf  # Inicializa com um valor muito baixo.
        for row in range(3):
            for col in range(3):
                if board[row, col] == 0:  # Se a célula estiver vazia
                    board[row, col] = 2  # Faz a jogada da IA temporariamente.
                    # Chama minimax recursivamente para o próximo turno (vez do humano, minimizando).
                    score = minimax(board, depth + 1, False)
                    board[row, col] = 0  # Desfaz a jogada (backtracking) para explorar outras opções.
                    best_score = max(score, best_score)  # A IA escolhe a jogada que maximiza seu score.
        return best_score
    else:  # Vez do Humano (minimizar o score da IA)
        best_score = np.inf  # Inicializa com um valor muito alto.
        for row in range(3):
            for col in range(3):
                if board[row, col] == 0:  # Se a célula estiver vazia
                    board[row, col] = 1  # Faz a jogada do Humano temporariamente.
                    # Chama minimax recursivamente para o próximo turno (vez da IA, maximizando).
                    score = minimax(board, depth + 1, True)
                    board[row, col] = 0  # Desfaz a jogada (backtracking).
                    best_score = min(score, best_score)  # O Humano escolhe a jogada que minimiza o score da IA.
        return best_score

def get_best_move(board):
    """
    Determina a melhor jogada para a IA usando o algoritmo Minimax.
    """
    best_score = -np.inf  # Inicializa o melhor score com um valor muito baixo.
    move = None           # Variável para armazenar a melhor jogada (linha, coluna).
    for row in range(3):
        for col in range(3):
            if board[row, col] == 0:  # Se a célula estiver vazia
                board[row, col] = 2  # Tenta a jogada da IA nesta célula.
                # Calcula o score para esta jogada, assumindo que o humano jogará otimamente depois (minimizará).
                score = minimax(board, 0, False)
                board[row, col] = 0  # Desfaz a jogada para explorar outras opções.
                if score > best_score:  # Se esta jogada resultar em um score melhor para a IA
                    best_score = score  # Atualiza o melhor score.
                    move = (row, col)   # Armazena esta jogada como a melhor até agora.
    return move  # Retorna a melhor jogada encontrada.

def play():
    """
    Gerencia o fluxo principal do jogo Jogo da Velha.
    """
    board = np.zeros((3, 3), dtype=int)  # Inicializa um tabuleiro 3x3 vazio (todos os valores são 0).
    human = 1  # Define o jogador humano como 'X'.
    ai = 2     # Define o jogador da IA como 'O'.

    while True:  # Loop principal do jogo, continua até que haja um vencedor ou empate.
        limpar_tela()    # Limpa a tela antes de cada atualização do tabuleiro.
        print_board(board)  # Imprime o tabuleiro atualizado.

        # Vez do Humano
        print("Sua vez (jogador X):")
        while True:  # Loop para garantir que o humano faça uma jogada válida.
            try:
                row = int(input("Linha (0, 1 ou 2): "))   # Pede a linha ao usuário.
                col = int(input("Coluna (0, 1 ou 2): "))  # Pede a coluna ao usuário.
                # Verifica se as coordenadas estão dentro do alcance válido e se a célula está vazia.
                if 0 <= row <= 2 and 0 <= col <= 2:
                    if board[row, col] == 0:
                        board[row, col] = human  # Faz a jogada do humano.
                        break  # Sai do loop de entrada de jogada válida.
                    else:
                        print("Espaço já ocupado. Tente novamente.")
                else:
                    print("Coordenadas fora do alcance. Use 0, 1 ou 2.")
            except ValueError:  # Captura erro se o usuário digitar algo que não seja um número.
                print("Entrada inválida. Tente novamente.")

        # Verifica se o humano venceu após sua jogada.
        if check_winner(board) == human:
            limpar_tela()
            print_board(board)
            print("Você venceu!")
            break  # Encerra o jogo.
        # Verifica se é um empate após a jogada do humano.
        if is_draw(board):
            limpar_tela()
            print_board(board)
            print("Empate!")
            break  # Encerra o jogo.

        # Vez da IA
        print("IA está jogando...")
        row, col = get_best_move(board)  # Obtém a melhor jogada da IA.
        board[row, col] = ai  # Faz a jogada da IA.

        # Verifica se a IA venceu após sua jogada.
        if check_winner(board) == ai:
            limpar_tela()
            print_board(board)
            print("A IA venceu!")
            break  # Encerra o jogo.
        # Verifica se é um empate após a jogada da IA.
        if is_draw(board):
            limpar_tela()
            print_board(board)
            print("Empate!")
            break  # Encerra o jogo.

if __name__ == "__main__":
    """
    Este bloco garante que a função play() seja chamada apenas quando o script é executado diretamente,
    e não quando é importado como um módulo em outro arquivo.
    """
    play()