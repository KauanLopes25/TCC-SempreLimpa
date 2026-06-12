-- =========================================================
-- BANCO DE DADOS - SEMPRE LIMPA
-- SCRIPT LIMPO PARA PRIMEIRA EXECUÇÃO
-- =========================================================
DROP DATABASE IF EXISTS sempre_limpa_db;
CREATE DATABASE sempre_limpa_db;
USE sempre_limpa_db;
-- =========================================================
-- TABELAS BASE
-- =========================================================
CREATE TABLE dados_bancarios (
    dados_bancarios_id INT PRIMARY KEY AUTO_INCREMENT,

    digito VARCHAR(1) NOT NULL,
    agencia VARCHAR(4) NOT NULL,

    banco ENUM(
        'nubank',
        'picpay',
        'mercadopago'
    ),

    tipo_conta ENUM(
        'corrente',
        'salario',
        'poupanca'
    ),

    conta INT NOT NULL
);

CREATE TABLE endereco (
    endereco_id INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE endereco_lavanderia (
    endereco_lavanderia_id INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE endereco_motorista (
    endereco_motorista_id INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE status_pedido(
    status_pedido_id INT PRIMARY KEY AUTO_INCREMENT,
    progresso ENUM(
  'SOLICITADO',
  'ATRIBUIDO',
  'COLETANDO',
  'EM_TRANSITO',
  'LAVANDO',
  'SECANDO',
  'RETORNANDO',
  'ENTREGUE',
  'CANCELADO'
) not null default 'SOLICITADO'
);

CREATE TABLE roupas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_peca VARCHAR(100) NOT NULL
);

-- =========================================================
-- USUÁRIOS, LAVANDERIAS e MOTORISTAS
-- =========================================================

CREATE TABLE usuario (
    usuario_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    e_mail VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(11),
    cpf VARCHAR(11) UNIQUE,
    rne VARCHAR(9),
    fk_endereco INT,
    senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,

    CONSTRAINT fk_usuario_endereco
        FOREIGN KEY (fk_endereco)
        REFERENCES endereco(endereco_id)
);

CREATE TABLE lavanderia (
    lavanderia_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(300),
    cnpj VARCHAR(14) UNIQUE NOT NULL,

    tempo_padrao_lavagem TIME,
    tempo_secagem TIME,

    preco_padrao_lavagem DECIMAL(10,2) NOT NULL,
    preco_padrao_secagem DECIMAL(10,2) NOT NULL,

    logo VARCHAR(255),
    e_mail VARCHAR(255),
    telefone VARCHAR(11),

    fk_endereco_lavanderia INT,

    CONSTRAINT fk_lavanderia_endereco
        FOREIGN KEY (fk_endereco_lavanderia)
        REFERENCES endereco_lavanderia(endereco_lavanderia_id)
);

CREATE TABLE motorista (
    motorista_id INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,

    cpf VARCHAR(11) NOT NULL,
    telefone VARCHAR(11) NOT NULL,
    email VARCHAR(100) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    cnh VARCHAR(11),
    foto VARCHAR(255) NOT NULL,
    status_motorista ENUM('OFFLINE','DISPONIVEL','OCUPADO') NOT NULL DEFAULT 'OFFLINE',

    fk_dados_bancarios_id INT NOT NULL,
    fk_endereco_motorista_id INT NOT NULL,

    CONSTRAINT fk_motorista_dados_bancarios
        FOREIGN KEY (fk_dados_bancarios_id)
        REFERENCES dados_bancarios(dados_bancarios_id),

    CONSTRAINT fk_motorista_endereco
        FOREIGN KEY (fk_endereco_motorista_id)
        REFERENCES endereco_motorista(endereco_motorista_id)
);

-- =========================================================
-- CARTÃO / FAVORITOS / AVALIAÇÃO
-- =========================================================

CREATE TABLE cartao (
    cartao_id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT,

    bandeira VARCHAR(20),
    validade VARCHAR(4),
    token_cartao VARCHAR(255),
    ultimos_digitos VARCHAR(4),

    CONSTRAINT fk_cartao_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(usuario_id)
);

CREATE TABLE favoritos (
    favoritos_id INT PRIMARY KEY AUTO_INCREMENT,

    fk_usuario_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,

    CONSTRAINT fk_favoritos_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id),

    CONSTRAINT fk_favoritos_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
);

CREATE TABLE avaliacao (
    avaliacao_id INT PRIMARY KEY AUTO_INCREMENT,

    nota INT CHECK (nota BETWEEN 1 AND 5),
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    comentario VARCHAR(255),

    fk_usuario_id INT,
    fk_lavanderia_id INT,

    CONSTRAINT fk_avaliacao_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id),

    CONSTRAINT fk_avaliacao_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
);

-- =========================================================
-- PEDIDOS
-- =========================================================

CREATE TABLE pedido (
    pedido_id INT PRIMARY KEY AUTO_INCREMENT,

    data DATETIME DEFAULT CURRENT_TIMESTAMP,

    valor_total DECIMAL(10,2),
    taxa_entrega DECIMAL(10,2),
    taxa_entregador DECIMAL(10,2),
    taxa_app DECIMAL(10,2),

    tempo_estimado TIME,

    fk_status_pedido_id INT,
    status_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fk_lavanderia_id INT,
    fk_usuario_id INT,
    fk_motorista_id INT,

    CONSTRAINT fk_pedido_status
        FOREIGN KEY (fk_status_pedido_id)
        REFERENCES status_pedido(status_pedido_id),

    CONSTRAINT fk_pedido_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id),

    CONSTRAINT fk_pedido_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id),
        
	CONSTRAINT fk_pedido_motorista
		FOREIGN KEY (fk_motorista_id)
        REFERENCES motorista(motorista_id)
);

-- =========================================================
-- CESTO
-- =========================================================

CREATE TABLE cesto (
    cesto_id INT PRIMARY KEY AUTO_INCREMENT,

    peso_estimado DECIMAL(5,2),

    secagem ENUM('SIM','NAO') DEFAULT 'NAO',

    tipo_lavagem ENUM('NORMAL','PESADA') DEFAULT 'NORMAL',

    fk_pedido_id INT,

    CONSTRAINT fk_cesto_pedido
        FOREIGN KEY (fk_pedido_id)
        REFERENCES pedido(pedido_id)
);

CREATE TABLE cesto_roupa (
    fk_cesto_id INT,
    fk_roupas_id INT,

    quantidade INT,
    cor VARCHAR(50) NOT NULL DEFAULT "Não específicado",

    PRIMARY KEY (fk_cesto_id, fk_roupas_id),

    CONSTRAINT fk_cesto_roupa_cesto
        FOREIGN KEY (fk_cesto_id)
        REFERENCES cesto(cesto_id),

    CONSTRAINT fk_cesto_roupa_roupa
        FOREIGN KEY (fk_roupas_id)
        REFERENCES roupas(id)
);

-- =========================================================
-- PAGAMENTO
-- =========================================================

CREATE TABLE ordem_pagamento (
    ordem_pagamento_id INT PRIMARY KEY AUTO_INCREMENT,

    tipo_pagamento ENUM('PIX','CARTAO') NOT NULL,

    valor DECIMAL(10,2) NOT NULL,

    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,

    status ENUM('PAGO','PENDENTE','CANCELADO')
    DEFAULT 'PENDENTE',

    fk_pedido_id INT,

    CONSTRAINT fk_ordem_pagamento_pedido
        FOREIGN KEY (fk_pedido_id)
        REFERENCES pedido(pedido_id)
);

CREATE TABLE pagamento_cartao (
    pagamento_cartao_id INT PRIMARY KEY AUTO_INCREMENT,

    token_utilizado VARCHAR(255),
    ultimos_digitos VARCHAR(4),

    tipo ENUM('DEBITO','CREDITO'),

    fk_cartao_id INT,
    fk_ordem_pagamento_id INT,

    CONSTRAINT fk_pagamento_cartao_cartao
        FOREIGN KEY (fk_cartao_id)
        REFERENCES cartao(cartao_id),

    CONSTRAINT fk_pagamento_cartao_ordem
        FOREIGN KEY (fk_ordem_pagamento_id)
        REFERENCES ordem_pagamento(ordem_pagamento_id)
);

CREATE TABLE pix (
    pix_id INT PRIMARY KEY AUTO_INCREMENT,

    chave_pix VARCHAR(255),
    data_expiracao DATETIME,
    qr_code VARCHAR(255),

    status ENUM('PAGO','PENDENTE','EXPIRADO')
    DEFAULT 'PENDENTE',

    fk_ordem_pagamento_id INT,

    CONSTRAINT fk_pix_ordem
        FOREIGN KEY (fk_ordem_pagamento_id)
        REFERENCES ordem_pagamento(ordem_pagamento_id)
);

CREATE TABLE cartao_usuario (
    fk_usuario_id INT NOT NULL,
    fk_cartao_id INT NOT NULL,

    PRIMARY KEY (fk_usuario_id, fk_cartao_id),

    CONSTRAINT fk_cartao_usuario_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_cartao_usuario_cartao
        FOREIGN KEY (fk_cartao_id)
        REFERENCES cartao(cartao_id)
        ON DELETE CASCADE
);
-- =========================================================
-- MOTORISTAS
-- =========================================================

CREATE TABLE avaliacao_motorista (
    avaliacao_motorista_id INT PRIMARY KEY AUTO_INCREMENT,

    data DATE NOT NULL,

    comentario VARCHAR(255) NOT NULL,

    nota INT,

    fk_motorista_id INT NOT NULL,
    fk_usuario_id INT NOT NULL,

    CONSTRAINT fk_avaliacao_motorista_motorista
        FOREIGN KEY (fk_motorista_id)
        REFERENCES motorista(motorista_id),

    CONSTRAINT fk_avaliacao_motorista_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id)
);

CREATE TABLE extrato (
    extrato_id INT PRIMARY KEY AUTO_INCREMENT,

    taxa_motorista DECIMAL(10,2),
    taxa_km DECIMAL(10,2),

    fk_motorista_id INT NOT NULL,
    fk_pedido_id INT NOT NULL,

    CONSTRAINT fk_extrato_motorista
        FOREIGN KEY (fk_motorista_id)
        REFERENCES motorista(motorista_id),

    CONSTRAINT fk_extrato_pedido
        FOREIGN KEY (fk_pedido_id)
        REFERENCES pedido(pedido_id)
);

CREATE TABLE cartao_virtual (
    cartao_virtual_id INT PRIMARY KEY AUTO_INCREMENT,

    numero INT NOT NULL,

    validade VARCHAR(5) NOT NULL,

    saldo DECIMAL(10,2),

    fk_motorista_id INT NOT NULL,

    CONSTRAINT fk_cartao_virtual_motorista
        FOREIGN KEY (fk_motorista_id)
        REFERENCES motorista(motorista_id)
);

CREATE TABLE dados_veiculo (
    dados_veiculo_id INT PRIMARY KEY AUTO_INCREMENT,

    placa VARCHAR(7) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,

    ano_modelo YEAR NOT NULL,
    ano_fabricacao YEAR NOT NULL,

    cor VARCHAR(50) NOT NULL
);

CREATE TABLE veiculo (
    veiculo_id INT PRIMARY KEY AUTO_INCREMENT,

    modalidade ENUM(
        'bike',
        'carro',
        'motocicleta'
    ),

    fk_motorista_id INT NOT NULL,
    fk_dados_veiculo_id INT NOT NULL,

    CONSTRAINT fk_veiculo_motorista
        FOREIGN KEY (fk_motorista_id)
        REFERENCES motorista(motorista_id),

    CONSTRAINT fk_veiculo_dados
        FOREIGN KEY (fk_dados_veiculo_id)
        REFERENCES dados_veiculo(dados_veiculo_id)
);

CREATE TABLE localizacao (
    localizacao_id INT PRIMARY KEY AUTO_INCREMENT,

    fk_motorista_id INT NULL,
    fk_usuario_id INT NULL,
    fk_lavanderia_id INT NULL,

    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_localizacao_motorista
        FOREIGN KEY (fk_motorista_id)
        REFERENCES motorista(motorista_id),
        
	CONSTRAINT fk_localizacao_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id),
        
	CONSTRAINT fk_localizacao_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id),
        
	CONSTRAINT chk_apenas_um
        CHECK (
            (fk_motorista_id IS NOT NULL AND fk_usuario_id IS NULL AND fk_lavanderia_id IS NULL)
            OR
            (fk_motorista_id IS NULL AND fk_usuario_id IS NOT NULL AND fk_lavanderia_id IS NULL)
            OR
            (fk_motorista_id IS NULL AND fk_usuario_id IS NULL AND fk_lavanderia_id IS NOT NULL)
        )
);

-- =========================================================
-- INSERTS
-- =========================================================

-- ENDEREÇOS USUÁRIOS

-- ENDEREÇOS LAVANDERIAS

INSERT INTO endereco_lavanderia (
    cep,
    uf,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento
)
VALUES
('01001000','SP','São Paulo','Centro','Praça da Sé','100','Sala 1'),
('04538132','SP','São Paulo','Itaim Bibi','Av Brigadeiro Faria Lima','3477','Térreo'),
('01310100','SP','São Paulo','Bela Vista','Av Paulista','1500','Loja A');

-- USUÁRIOS

-- LAVANDERIAS

INSERT INTO lavanderia (
    nome,
    descricao,
    cnpj,
    tempo_padrao_lavagem,
    tempo_secagem,
    preco_padrao_lavagem,
    preco_padrao_secagem,
    logo,
    e_mail,
    telefone,
    fk_endereco_lavanderia
)
VALUES
(
    '5asec',
    'Lavagem premium',
    '04078995000245',
    '01:00:00',
    '00:30:00',
    30.00,
    15.00,
    'logo1.png',
    '5asec@test.com',
    '11999999998',
    1
),
(
    'White Bubble',
    'Lavagem ecológica',
    '12345678000199',
    '01:30:00',
    '00:40:00',
    25.50,
    12.00,
    'logo2.png',
    'bubble@test.com',
    '11988888888',
    2
),
(
    'Super Clean',
    'Lavagem pesada',
    '98765432000188',
    '02:00:00',
    '01:00:00',
    40.00,
    20.00,
    'logo3.png',
    'superclean@test.com',
    '11977777777',
    3
);

-- CARTÕES

-- FAVORITOS

-- AVALIAÇÕES

-- PEDIDOS

-- CESTO

-- ROUPAS

INSERT INTO roupas (
    nome_peca
)
VALUES
('Camiseta'),
('Calça'),
('Cobertor');

-- CESTO ROUPA

-- ORDEM PAGAMENTO

-- PIX

-- PAGAMENTO CARTÃO

-- =========================================================
-- VIEWS
-- =========================================================

-- View para perfil completo do usuário
CREATE OR REPLACE VIEW vw_usuario_endereco_detalhado AS
SELECT
    u.usuario_id,

    u.fk_endereco AS endereco_id,

    u.nome,
    u.e_mail,
    u.cpf,
    u.telefone,
    u.data_nascimento,

    e.cep,
    e.uf,
    e.cidade,
    e.bairro,
    e.logradouro,
    e.numero,
    e.complemento

FROM usuario u

INNER JOIN endereco e
    ON e.endereco_id = u.fk_endereco;

-- View para filtro de lavanderia por avaliação
CREATE VIEW vw_avaliacoes AS
SELECT
    l.nome AS lavanderia,
    u.nome AS usuario,
    a.nota,
    a.comentario,
    a.data
FROM avaliacao a
INNER JOIN usuario u
    ON u.usuario_id = a.fk_usuario_id
INNER JOIN lavanderia l
    ON l.lavanderia_id = a.fk_lavanderia_id;

-- View para filtro de media de avaliação das lavanderias
CREATE VIEW vw_media_lavanderia AS
SELECT
    l.lavanderia_id,
    l.nome,
    ROUND(AVG(a.nota),1) AS media_avaliacao
FROM lavanderia l
LEFT JOIN avaliacao a
    ON a.fk_lavanderia_id = l.lavanderia_id
GROUP BY l.lavanderia_id, l.nome;

-- View para perfil completo do usuário
CREATE VIEW vw_usuario_endereco_perfil AS
SELECT
    u.usuario_id,
    u.nome,

    CONCAT(
        e.logradouro, ', ',
        e.numero, ' - ',
        e.bairro, ', ',
        e.cidade, ' - ',
        e.uf, ' CEP: ',
        e.cep
    ) AS endereco_completo

FROM usuario u
INNER JOIN endereco e
    ON e.endereco_id = u.fk_endereco;

-- View para pedido completo
CREATE VIEW vw_pedido_completo AS
SELECT
    p.pedido_id,
    u.nome AS usuario,
    l.nome AS lavanderia,
    p.valor_total,
    p.taxa_entrega,
    p.tempo_estimado,
    s.progresso AS status_pedido,
    p.data
FROM pedido p
INNER JOIN usuario u
    ON u.usuario_id = p.fk_usuario_id
INNER JOIN lavanderia l
    ON l.lavanderia_id = p.fk_lavanderia_id
INNER JOIN status_pedido s
    ON s.status_pedido_id = p.fk_status_pedido_id;

-- View para pagamento detalhado
CREATE VIEW vw_pagamento_detalhado AS
SELECT
    op.ordem_pagamento_id,
    op.tipo_pagamento,
    op.valor,
    op.status,

    p.pedido_id,

    pc.tipo AS tipo_cartao,

    px.status AS status_pix

FROM ordem_pagamento op

LEFT JOIN pagamento_cartao pc
    ON pc.fk_ordem_pagamento_id = op.ordem_pagamento_id

LEFT JOIN pix px
    ON px.fk_ordem_pagamento_id = op.ordem_pagamento_id

INNER JOIN pedido p
    ON p.pedido_id = op.fk_pedido_id;

-- View para cestos de roupas
CREATE VIEW vw_cesto_roupas AS
SELECT
    c.cesto_id,
    r.nome_peca,
    cr.quantidade
FROM cesto c
INNER JOIN cesto_roupa cr
    ON cr.fk_cesto_id = c.cesto_id
INNER JOIN roupas r
    ON r.id = cr.fk_roupas_id;

CREATE VIEW vw_favoritos_usuario AS
SELECT
    u.nome AS usuario,
    l.nome AS lavanderia
FROM favoritos f
INNER JOIN usuario u
    ON u.usuario_id = f.fk_usuario_id
INNER JOIN lavanderia l
    ON l.lavanderia_id = f.fk_lavanderia_id;

-- View para visualizaão de lavanderias completas
CREATE VIEW vw_lavanderias_completas AS
SELECT
    l.lavanderia_id,
    l.nome,
    l.descricao,
    l.preco_padrao_lavagem,
    l.preco_padrao_secagem,
    l.logo,
    l.telefone,

    e.cidade,
    e.uf,
    e.bairro,
    e.logradouro,
    e.numero

FROM lavanderia l

INNER JOIN endereco_lavanderia e
    ON l.fk_endereco_lavanderia =
       e.endereco_lavanderia_id;

-- View para filtro de lavanderias por preço
CREATE VIEW vw_lavanderias_preco AS
SELECT
    lavanderia_id,
    nome,
    preco_padrao_lavagem,
    preco_padrao_secagem,

    (
        preco_padrao_lavagem +
        preco_padrao_secagem
    ) / 2 AS preco_medio

FROM lavanderia;

-- View para filtro de lavandeiras com mais pedidos feitos
CREATE VIEW vw_lavanderias_populares AS
SELECT
    l.lavanderia_id,
    l.nome,

    COUNT(p.pedido_id) AS total_pedidos

FROM lavanderia l

LEFT JOIN pedido p
    ON p.fk_lavanderia_id = l.lavanderia_id

GROUP BY l.lavanderia_id, l.nome

ORDER BY total_pedidos DESC;

-- View para pedidos do usuário na home
CREATE OR REPLACE VIEW vw_home_usuario_pedidos AS
SELECT
    p.pedido_id,

    u.usuario_id,
    u.nome AS nome_usuario,

    s.progresso AS status_pedido,

    p.valor_total,

    p.tempo_estimado,

    p.data AS data_pedido,

    (SELECT COUNT(*) FROM cesto c WHERE c.fk_pedido_id = p.pedido_id) AS quantidade_cestos

FROM pedido p

INNER JOIN usuario u
    ON u.usuario_id = p.fk_usuario_id

INNER JOIN status_pedido s
    ON s.status_pedido_id = p.fk_status_pedido_id

LEFT JOIN cesto c
    ON c.fk_pedido_id = p.pedido_id

GROUP BY
    p.pedido_id,
    u.usuario_id,
    u.nome,
    s.progresso,
    p.valor_total,
    p.tempo_estimado,
    p.data;
    
-- View para filtros de lavanderias
CREATE OR REPLACE VIEW vw_lavanderias_filtros AS
SELECT 
    l.lavanderia_id,
    l.nome,
    l.descricao,
    l.tempo_padrao_lavagem,
    l.preco_padrao_lavagem,
    l.tempo_secagem,
    l.preco_padrao_secagem,
    l.logo,
    e.cidade,
    e.bairro,
    e.uf,
    COALESCE(ROUND(AVG(a.nota), 1), 0) AS media_avaliacao
FROM 
    lavanderia l
INNER JOIN 
    endereco_lavanderia e ON l.fk_endereco_lavanderia = e.endereco_lavanderia_id
LEFT JOIN 
    avaliacao a ON l.lavanderia_id = a.fk_lavanderia_id
GROUP BY 
    l.lavanderia_id, 
    l.nome, 
    l.descricao,
    l.tempo_padrao_lavagem,
    l.preco_padrao_lavagem,
    l.tempo_secagem,
    l.preco_padrao_secagem,
    l.logo,
    e.cidade, 
    e.bairro, 
    e.uf;
    
-- View para visualização das lavandeiras
CREATE OR REPLACE VIEW vw_lavanderia_endereco AS
SELECT 
    l.*, 
    e.cep,
    e.uf,
    e.cidade,
    e.bairro,
    e.logradouro,
    e.numero,
    e.complemento,
    COALESCE(ROUND(AVG(a.nota), 1), 0) AS media_avaliacao
FROM 
    lavanderia AS l
INNER JOIN 
    endereco_lavanderia AS e 
    ON l.fk_endereco_lavanderia = e.endereco_lavanderia_id
LEFT JOIN 
    avaliacao AS a 
    ON l.lavanderia_id = a.fk_lavanderia_id
GROUP BY 
    l.lavanderia_id, 
    e.endereco_lavanderia_id;

-- View para detalhes completos do pedido, incluindo status, lavanderia, motorista, pagamento, cesto e roupas
CREATE OR REPLACE VIEW vw_detalhes_pedido AS
SELECT
    p.pedido_id,

    p.data,

    p.valor_total,
    p.taxa_entrega,
    p.taxa_entregador,
    p.taxa_app,

    p.tempo_estimado,

    s.progresso AS status_pedido,

    l.nome AS lavanderia,

    m.nome AS motorista,

    op.tipo_pagamento,
    op.status AS status_pagamento,

    c.cesto_id,
    c.peso_estimado,
    c.secagem,
    c.tipo_lavagem,

    r.nome_peca,

    cr.quantidade

FROM pedido p

INNER JOIN status_pedido s
    ON s.status_pedido_id = p.fk_status_pedido_id

INNER JOIN lavanderia l
    ON l.lavanderia_id = p.fk_lavanderia_id

LEFT JOIN motorista m
    ON m.motorista_id = p.fk_motorista_id

LEFT JOIN ordem_pagamento op
    ON op.fk_pedido_id = p.pedido_id

LEFT JOIN cesto c
    ON c.fk_pedido_id = p.pedido_id

LEFT JOIN cesto_roupa cr
    ON cr.fk_cesto_id = c.cesto_id

LEFT JOIN roupas r
    ON r.id = cr.fk_roupas_id;
-- =========================================================
-- TRIGGERS
-- =========================================================

DELIMITER $$

CREATE TRIGGER trg_valida_nota
BEFORE INSERT ON avaliacao
FOR EACH ROW
BEGIN

    IF NEW.nota < 1 OR NEW.nota > 5 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Nota deve ser entre 1 e 5';

    END IF;

END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_valor_total_pedido
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN

    SET NEW.valor_total =
        IFNULL(NEW.valor_total,0) +
        IFNULL(NEW.taxa_entrega,0) +
        IFNULL(NEW.taxa_entregador,0) +
        IFNULL(NEW.taxa_app,0);

END $$

DELIMITER ;

-- =========================================================
-- PROCEDURE
-- =========================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_criar_pedido_completo $$

CREATE PROCEDURE sp_criar_pedido_completo (
    IN p_usuario INT,
    IN p_lavanderia INT,
    IN p_valor DECIMAL(10,2),
    IN p_taxa_entrega DECIMAL(10,2),
    IN p_tipo_pagamento ENUM('PIX','CARTAO'),
    IN p_cartao_id INT,
    IN p_tipo_cartao ENUM('DEBITO','CREDITO'),
    OUT p_pedido_id INT
)
BEGIN

    DECLARE v_pedido_id INT;
    DECLARE v_ordem_id INT;
    DECLARE v_valor_final DECIMAL(10,2);
    DECLARE v_cartao_existe INT DEFAULT 0;
    DECLARE v_taxa_entregador DECIMAL(10,2) DEFAULT 00.00;
    DECLARE v_taxa_app DECIMAL(10,2) DEFAULT 6.00;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SET v_valor_final =
        p_valor +
        p_taxa_entrega +
        v_taxa_entregador +
        v_taxa_app;

    INSERT INTO pedido (
        data,
        valor_total,
        taxa_entrega,
        taxa_entregador,
        taxa_app,
        tempo_estimado,
        fk_status_pedido_id,
        fk_lavanderia_id,
        fk_usuario_id
    )
    VALUES (
        NOW(),
        p_valor,
        p_taxa_entrega,
        v_taxa_entregador,
        v_taxa_app,
        '01:00:00',
        1,
        p_lavanderia,
        p_usuario
    );

    SET v_pedido_id = LAST_INSERT_ID();

    INSERT INTO ordem_pagamento (
        tipo_pagamento,
        valor,
        data_criacao,
        status, 
        fk_pedido_id
    )
    VALUES (
        p_tipo_pagamento,
        v_valor_final,
        NOW(),
        'PENDENTE',
        v_pedido_id
    );

    SET v_ordem_id = LAST_INSERT_ID();

    IF p_tipo_pagamento = 'PIX' THEN

        INSERT INTO pix (
            chave_pix,
            data_expiracao,
            qr_code,
            status, 
            fk_ordem_pagamento_id
        )
        VALUES (
            CONCAT('pix_', v_ordem_id),
            DATE_ADD(NOW(), INTERVAL 30 MINUTE),
            CONCAT('qr_', v_ordem_id),
            'PENDENTE',
            v_ordem_id
        );

    ELSEIF p_tipo_pagamento = 'CARTAO' THEN

        IF p_cartao_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cartão obrigatório';
        END IF;

        SELECT COUNT(*)
        INTO v_cartao_existe
        FROM cartao
        WHERE cartao_id = p_cartao_id;

        IF v_cartao_existe = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cartão não encontrado';
        END IF;

        INSERT INTO pagamento_cartao (
            token_utilizado,
            ultimos_digitos,
            tipo,
            fk_cartao_id,
            fk_ordem_pagamento_id
        )
        SELECT
            token_cartao,
            ultimos_digitos,
            p_tipo_cartao,
            cartao_id,
            v_ordem_id
        FROM cartao
        WHERE cartao_id = p_cartao_id;

    END IF;

    SET p_pedido_id = v_pedido_id;

    COMMIT;

END $$

DELIMITER ;

-- =========================================================
-- INSERTS
-- =========================================================

-- STATUS

INSERT INTO status_pedido (progresso) VALUES
('SOLICITADO'),
('ATRIBUIDO'),
('COLETANDO'),
('EM_TRANSITO'),
('LAVANDO'),
('SECANDO'),
('RETORNANDO'),
('ENTREGUE'),
('CANCELADO');

-- ENDEREÇOS USUÁRIOS

INSERT INTO endereco (
    cep,
    uf,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento
)
VALUES (
    '18160000',
    'SP',
    'Salto de Pirapora',
    'Centro',
    'Rua José Benedito de Oliveira',
    '123',
    'Casa'
);

-- ENDEREÇOS LAVANDERIAS

INSERT INTO endereco_lavanderia (
    cep,
    uf,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento
)
VALUES
('01001000','SP','São Paulo','Centro','Praça da Sé','100','Sala 1'),
('04538132','SP','São Paulo','Itaim Bibi','Av Brigadeiro Faria Lima','3477','Térreo'),
('01310100','SP','São Paulo','Bela Vista','Av Paulista','1500','Loja A');

INSERT INTO usuario (
    nome,
    e_mail,
    telefone,
    cpf,
    fk_endereco,
    senha,
    data_nascimento
)
VALUES (
    'Kauan Lopes',
    'kauan.lopes02@hotmail.com',
    '15999999999',
    '38748497835',
    1,
    '$2b$10$senhahash',
    '2000-01-01'
);

-- LAVANDERIAS

INSERT INTO lavanderia (
    nome,
    descricao,
    cnpj,
    tempo_padrao_lavagem,
    tempo_secagem,
    preco_padrao_lavagem,
    preco_padrao_secagem,
    logo,
    e_mail,
    telefone,
    fk_endereco_lavanderia
)
VALUES
(
    '5asec',
    'Lavagem premium',
    '04078995090245',
    '01:00:00',
    '00:30:00',
    30.00,
    15.00,
    'logo1.png',
    '5asec@test.com',
    '11999999998',
    1
),
(
    'White Bubble',
    'Lavagem ecológica',
    '12345678040199',
    '01:30:00',
    '00:40:00',
    25.50,
    12.00,
    'logo2.png',
    'bubble@test.com',
    '11988888888',
    2
),
(
    'Super Clean',
    'Lavagem pesada',
    '98765432060188',
    '02:00:00',
    '01:00:00',
    40.00,
    20.00,
    'logo3.png',
    'superclean@test.com',
    '11977777777',
    3
);

-- CARTÕES

-- FAVORITOS

-- AVALIAÇÕES

-- ROUPAS
INSERT INTO roupas (nome_peca) VALUES
('Camiseta'),
('Camisa Social'),
('Calça Jeans'),
('Calça Social'),
('Bermuda'),
('Short'),
('Vestido'),
('Saia'),
('Blusa'),
('Moletom'),
('Jaqueta'),
('Casaco'),
('Terno'),
('Blazer'),
('Gravata'),
('Pijama'),
('Roupa Íntima'),
('Meia'),
('Toalha de Banho'),
('Toalha de Rosto'),
('Lençol'),
('Fronha'),
('Cobertor'),
('Edredom'),
('Manta'),
('Tapete'),
('Cortina'),
('Uniforme Escolar'),
('Uniforme Profissional'),
('Avental'),
('Macacão'),
('Roupa de Bebê'),
('Roupa de Academia'),
('Roupa de Praia'),
('Biquíni'),
('Sunga'),
('Tênis'),
('Boné'),
('Cachecol'),
('Luvas');

-- ORDEM PAGAMENTO

-- PIX

-- PAGAMENTO CARTÃO

-- ==========================================
-- DADOS BANCÁRIOS
-- ==========================================

INSERT INTO dados_bancarios (
    digito,
    agencia,
    banco,
    tipo_conta,
    conta
)
VALUES
('1', '1234', 'nubank', 'corrente', 123456),
('2', '5678', 'mercadopago', 'poupanca', 654321);

-- ==========================================
-- ENDEREÇOS MOTORISTAS
-- ==========================================

INSERT INTO endereco_motorista (
    cep,
    uf,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento
)
VALUES
(
    '01001000',
    'SP',
    'São Paulo',
    'Centro',
    'Rua da Consolação',
    '100',
    'Apto 12'
),
(
    '13010000',
    'SP',
    'Campinas',
    'Cambuí',
    'Rua Barreto Leme',
    '250',
    'Casa'
);

-- ==========================================
-- MOTORISTAS
-- ==========================================

INSERT INTO motorista (
    nome,
    data_nascimento,
    cpf,
    telefone,
    email,
    senha,
    cnh,
    foto,
    fk_dados_bancarios_id,
    fk_endereco_motorista_id
)
VALUES
(
    'Carlos Silva',
    '1990-05-10',
    '12345678901',
    '11999999999',
    'carlos@motorista.com',
    '$2b$10$senhahash',
    '12345678901',
    'carlos.jpg',
    1,
    1
),
(
    'Marcos Souza',
    '1988-11-22',
    '98765432100',
    '11988888888',
    'marcos@motorista.com',
    '$2b$10$senhahash',
    '98765432100',
    'marcos.jpg',
    2,
    2
);

-- ==========================================
-- PEDIDOS
-- Status:
-- 1 = PENDENTE
-- 2 = PAGO
-- 3 = EM_ANDAMENTO
-- 4 = FINALIZADO
-- 5 = CANCELADO
-- ==========================================

INSERT INTO pedido (
    valor_total,
    taxa_entrega,
    taxa_entregador,
    taxa_app,
    tempo_estimado,
    fk_status_pedido_id,
    fk_lavanderia_id,
    fk_usuario_id,
    fk_motorista_id
)
VALUES
(
    80.00,
    10.00,
    20.00,
    6.00,
    '01:30:00',
    3,
    1,
    1,
    1
),
(
    120.00,
    12.00,
    20.00,
    6.00,
    '02:00:00',
    4,
    2,
    1,
    2
);

-- CESTOS

INSERT INTO cesto (
    peso_estimado,
    secagem,
    tipo_lavagem,
    fk_pedido_id
)
VALUES
(
    5.50,
    'SIM',
    'NORMAL',
    1
),
(
    8.20,
    'NAO',
    'PESADA',
    2
);

INSERT INTO cesto (
    peso_estimado,
    secagem,
    tipo_lavagem,
    fk_pedido_id
)
VALUES
(
    3.00,
    'SIM',
    'NORMAL',
    1
),
(
    6.50,
    'SIM',
    'PESADA',
    2
);