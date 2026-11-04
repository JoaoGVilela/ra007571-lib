/*
TRABALHO PRÁTICO 01 - GESTÃO DE BANCO DE DADOS (POSTGRESQL)
Tema: Sistema de gerenciamento de oficina mecânica.

JUSTIFICATIVA E CONTEXTUALIZAÇÃO:
O tema foi escolhido porque uma oficina mecânica precisa organizar clientes,
veículos, funcionários, ordens de serviço e os serviços realizados. O banco
permite registrar atendimentos, acompanhar os serviços executados e consultar
o histórico de cada veículo.

O script cria seis tabelas relacionadas, aplica PK, FK, NOT NULL, UNIQUE,
DEFAULT e CHECK, insere dados de exemplo e apresenta consultas SQL.
*/

DROP TABLE IF EXISTS item_ordem_servico CASCADE;
DROP TABLE IF EXISTS ordem_servico CASCADE;
DROP TABLE IF EXISTS servico CASCADE;
DROP TABLE IF EXISTS funcionario CASCADE;
DROP TABLE IF EXISTS veiculo CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;

CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(120) UNIQUE
);

CREATE TABLE veiculo (
    id_veiculo SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente),
    placa CHAR(7) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(60) NOT NULL,
    ano INTEGER NOT NULL CHECK (ano BETWEEN 1950 AND 2100)
);

CREATE TABLE funcionario (
    id_funcionario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario NUMERIC(10,2) NOT NULL CHECK (salario > 0),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE servico (
    id_servico SERIAL PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL UNIQUE,
    valor_base NUMERIC(10,2) NOT NULL CHECK (valor_base >= 0),
    tempo_estimado_horas NUMERIC(4,1) NOT NULL CHECK (tempo_estimado_horas > 0)
);

CREATE TABLE ordem_servico (
    id_ordem SERIAL PRIMARY KEY,
    id_veiculo INTEGER NOT NULL REFERENCES veiculo(id_veiculo),
    id_funcionario INTEGER NOT NULL REFERENCES funcionario(id_funcionario),
    data_abertura DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'Aberta'
        CHECK (status IN ('Aberta', 'Em andamento', 'Concluida', 'Cancelada')),
    observacao TEXT
);

CREATE TABLE item_ordem_servico (
    id_item SERIAL PRIMARY KEY,
    id_ordem INTEGER NOT NULL REFERENCES ordem_servico(id_ordem) ON DELETE CASCADE,
    id_servico INTEGER NOT NULL REFERENCES servico(id_servico),
    quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    valor_unitario NUMERIC(10,2) NOT NULL CHECK (valor_unitario >= 0),
    UNIQUE (id_ordem, id_servico)
);

-- CLIENTES
INSERT INTO cliente (nome, cpf, telefone, email) VALUES
('Carlos Mendes', '12345678901', '(35) 99911-1001', 'carlos@email.com'),
('Mariana Souza', '12345678902', '(35) 99911-1002', 'mariana@email.com'),
('Pedro Oliveira', '12345678903', '(35) 99911-1003', 'pedro@email.com'),
('Ana Ribeiro', '12345678904', '(35) 99911-1004', 'ana@email.com'),
('Lucas Ferreira', '12345678905', '(35) 99911-1005', 'lucas@email.com'),
('Fernanda Costa', '12345678906', '(35) 99911-1006', 'fernanda@email.com');

-- VEICULOS
INSERT INTO veiculo (id_cliente, placa, marca, modelo, ano) VALUES
(1, 'ABC1D23', 'Fiat', 'Uno', 2012),
(2, 'DEF4G56', 'Volkswagen', 'Gol', 2018),
(3, 'GHI7J89', 'Chevrolet', 'Onix', 2020),
(4, 'JKL1M23', 'Ford', 'Ka', 2017),
(5, 'MNO4P56', 'Toyota', 'Corolla', 2022),
(6, 'QRS7T89', 'Honda', 'Civic', 2019);

-- FUNCIONARIOS
INSERT INTO funcionario (nome, cargo, salario) VALUES
('Roberto Alves', 'Mecânico', 2800.00),
('Juliana Martins', 'Mecânica', 3000.00),
('Paulo Santos', 'Eletricista', 3200.00),
('Bruno Lima', 'Mecânico', 2750.00),
('Camila Rocha', 'Atendente', 2400.00),
('Diego Nunes', 'Mecânico', 2900.00);

-- SERVICOS
INSERT INTO servico (descricao, valor_base, tempo_estimado_horas) VALUES
('Troca de óleo', 120.00, 1.0),
('Alinhamento e balanceamento', 150.00, 1.5),
('Revisão de freios', 280.00, 2.0),
('Troca de bateria', 350.00, 1.0),
('Diagnóstico eletrônico', 180.00, 1.0),
('Troca de correia dentada', 600.00, 4.0);

-- ORDENS DE SERVICO
INSERT INTO ordem_servico (id_veiculo, id_funcionario, data_abertura, status, observacao) VALUES
(1, 1, '2026-10-20', 'Concluida', 'Revisão preventiva'),
(2, 2, '2026-10-21', 'Em andamento', 'Verificar ruído na suspensão'),
(3, 3, '2026-10-22', 'Concluida', 'Luz de injeção acesa'),
(4, 4, '2026-10-23', 'Aberta', 'Cliente solicitou avaliação'),
(5, 6, '2026-10-24', 'Concluida', 'Manutenção programada'),
(6, 1, '2026-10-25', 'Cancelada', 'Atendimento cancelado pelo cliente');

-- ITENS DAS ORDENS
INSERT INTO item_ordem_servico (id_ordem, id_servico, quantidade, valor_unitario) VALUES
(1, 1, 1, 120.00),
(1, 2, 1, 150.00),
(2, 3, 1, 280.00),
(3, 5, 1, 180.00),
(4, 4, 1, 350.00),
(5, 6, 1, 600.00),
(6, 1, 1, 120.00);

-- CONSULTA 1: ordens com cliente, veículo e funcionário (JOIN).
SELECT os.id_ordem, c.nome AS cliente, v.modelo, v.placa,
       f.nome AS funcionario, os.data_abertura, os.status
FROM ordem_servico os
JOIN veiculo v ON os.id_veiculo = v.id_veiculo
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN funcionario f ON os.id_funcionario = f.id_funcionario
ORDER BY os.id_ordem;

-- CONSULTA 2: total de cada ordem (JOIN, GROUP BY e SUM).
SELECT os.id_ordem, c.nome AS cliente,
       SUM(ios.quantidade * ios.valor_unitario) AS total_ordem
FROM ordem_servico os
JOIN veiculo v ON os.id_veiculo = v.id_veiculo
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN item_ordem_servico ios ON os.id_ordem = ios.id_ordem
GROUP BY os.id_ordem, c.nome
ORDER BY os.id_ordem;

-- CONSULTA 3: quantidade de ordens por status (GROUP BY).
SELECT status, COUNT(*) AS quantidade
FROM ordem_servico
GROUP BY status
ORDER BY status;

-- CONSULTA 4: serviços com valor acima de R$ 150,00 (filtro condicional).
SELECT descricao, valor_base
FROM servico
WHERE valor_base > 150.00
ORDER BY valor_base DESC;

-- CONSULTA 5: histórico de veículos de um cliente (filtro + JOIN).
SELECT c.nome AS cliente, v.marca, v.modelo, os.data_abertura, os.status
FROM cliente c
JOIN veiculo v ON c.id_cliente = v.id_cliente
JOIN ordem_servico os ON v.id_veiculo = os.id_veiculo
WHERE c.nome = 'Carlos Mendes'
ORDER BY os.data_abertura DESC;

-- CONSULTA 6: valor total gerado por cada serviço (JOIN + GROUP BY).
SELECT s.descricao,
       SUM(ios.quantidade) AS quantidade_realizada,
       SUM(ios.quantidade * ios.valor_unitario) AS faturamento
FROM servico s
JOIN item_ordem_servico ios ON s.id_servico = ios.id_servico
GROUP BY s.id_servico, s.descricao
ORDER BY faturamento DESC;
