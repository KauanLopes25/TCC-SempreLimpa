-- =========================================================
-- TABELAS BASE
-- =========================================================

CREATE TABLE endereco (
    endereco_id INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(11) NOT NULL,
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
    rne VARCHAR(9),
    fk_endereco INT,
    senha VARCHAR(12) NOT NULL,

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
