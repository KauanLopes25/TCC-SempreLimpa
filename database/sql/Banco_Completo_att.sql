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

CREATE TABLE status (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE roupas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_peca VARCHAR(100) NOT NULL
);

-- =========================================================
-- USUÁRIOS E LAVANDERIAS
-- =========================================================

CREATE TABLE usuario (
    usuario_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    e_mail VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(11),
    cpf VARCHAR(11) UNIQUE,
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

    fk_status_id INT,
    fk_lavanderia_id INT,
    fk_usuario_id INT,

    CONSTRAINT fk_pedido_status
        FOREIGN KEY (fk_status_id)
        REFERENCES status(status_id),

    CONSTRAINT fk_pedido_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id),

    CONSTRAINT fk_pedido_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id)
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

CREATE TABLE dados_veiculo (
    dados_veiculo_id INT PRIMARY KEY AUTO_INCREMENT,

    placa VARCHAR(7) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,

    ano_modelo YEAR NOT NULL,
    ano_fabricacao YEAR NOT NULL,

    cor VARCHAR(50) NOT NULL
);

CREATE TABLE motorista (
    motorista_id INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,

    cpf VARCHAR(11) NOT NULL,
    telefone VARCHAR(11) NOT NULL,
    email VARCHAR(100) NOT NULL,

    cnh VARCHAR(11),

    foto VARCHAR(255) NOT NULL,

    fk_dados_bancarios_id INT NOT NULL,
    fk_endereco_id INT NOT NULL,

    CONSTRAINT fk_motorista_dados_bancarios
        FOREIGN KEY (fk_dados_bancarios_id)
        REFERENCES dados_bancarios(dados_bancarios_id),

    CONSTRAINT fk_motorista_endereco
        FOREIGN KEY (fk_endereco_id)
        REFERENCES endereco(endereco_id)
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

-- =========================================================
-- INSERTS
-- =========================================================

-- STATUS

INSERT INTO status (descricao)
VALUES
('PENDENTE'),
('PAGO'),
('EM_ANDAMENTO'),
('FINALIZADO'),
('CANCELADO');

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

CREATE VIEW vw_media_lavanderia AS
SELECT
    l.lavanderia_id,
    l.nome,
    ROUND(AVG(a.nota),1) AS media_avaliacao
FROM lavanderia l
LEFT JOIN avaliacao a
    ON a.fk_lavanderia_id = l.lavanderia_id
GROUP BY l.lavanderia_id, l.nome;

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

CREATE VIEW vw_pedido_completo AS
SELECT
    p.pedido_id,
    u.nome AS usuario,
    l.nome AS lavanderia,
    p.valor_total,
    p.taxa_entrega,
    p.tempo_estimado,
    s.descricao AS status,
    p.data
FROM pedido p
INNER JOIN usuario u
    ON u.usuario_id = p.fk_usuario_id
INNER JOIN lavanderia l
    ON l.lavanderia_id = p.fk_lavanderia_id
INNER JOIN status s
    ON s.status_id = p.fk_status_id;

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

    DECLARE v_taxa_entregador DECIMAL(10,2)
    DEFAULT 20.00;

    DECLARE v_taxa_app DECIMAL(10,2)
    DEFAULT 6.00;

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
        fk_status_id,
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
            SET MESSAGE_TEXT =
            'Cartão obrigatório';

        END IF;

        SELECT COUNT(*)
        INTO v_cartao_existe
        FROM cartao
        WHERE cartao_id = p_cartao_id;

        IF v_cartao_existe = 0 THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Cartão não encontrado';

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