from collections import deque

matriz = [
    [0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0],
    [1, 1, 1, 0, 1],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 1, 1],
    [0, 0, 0, 0, 0]
]

# Tamanho da matriz
linhas = len(matriz)
colunas = len(matriz[0])

# Direções: cima, baixo, esquerda, direita
direcoes = [(-1,0), (1,0), (0,-1), (0,1)]

# BFS a partir de (0,0)
inicio = (0, 0)

visitado = [[False]*colunas for _ in range(linhas)]
fila = deque()

# Inicia BFS
fila.append(inicio)
visitado[0][0] = True

while fila:
    x, y = fila.popleft()
    print(f"Visitando: ({x}, {y})")

    for dx, dy in direcoes:
        nx, ny = x + dx, y + dy

        # Verifica se a nova posição está dentro dos limites
        if 0 <= nx < linhas and 0 <= ny < colunas:
            # Visita apenas os zeros e que ainda não foram visitados
            if not visitado[nx][ny] and matriz[nx][ny] == 0:
                visitado[nx][ny] = True
                fila.append((nx, ny))
