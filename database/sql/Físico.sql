CREATE DATABASE IF NOT EXISTS sempre_limpa_db;
USE sempre_limpa_db;

-- 2. TABELAS INDEPENDENTES (NÍVEL 1)
CREATE TABLE IF NOT EXISTS endereco (
    endereco_id INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(11) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS endereco_lavanderia (
    endereco_lavanderia_id INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS status (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS roupa (
    roupa_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_peca VARCHAR(100) NOT NULL
);

-- 3. TABELAS DEPENDENTES (NÍVEL 2 - Entidades com FK para o Nível 1)
CREATE TABLE IF NOT EXISTS usuario (
    usuario_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    e_mail VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(11),
    cpf VARCHAR(11) UNIQUE,
    rne VARCHAR(9),
    fk_endereco INT,
    senha VARCHAR(12) NOT NULL,
    CONSTRAINT fk_usuario_endereco FOREIGN KEY (fk_endereco) REFERENCES endereco(endereco_id)
);

CREATE TABLE IF NOT EXISTS lavanderia (
    lavanderia_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(300),
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    tempo_padrao_lavagem TIME,
    tempo_secagem TIME,
    preco_padrao_lavagem decimal(10,2),
    preco_padrao_secagem decimal(10,2),
    logo VARCHAR(255),
    e_mail VARCHAR(255),
    telefone VARCHAR(11),
    fk_endereco_lavanderia INT,
    CONSTRAINT fk_lavanderia_endereco_lavanderia FOREIGN KEY (fk_endereco_lavanderia) REFERENCES endereco_lavanderia(endereco_lavanderia_id)
);

-- 4. TABELAS DE FLUXO (NÍVEL 3 - Dependem de Usuário/Lavanderia/Status)
CREATE TABLE IF NOT EXISTS cartao (
    cartao_id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT,
    bandeira VARCHAR(20),
    validade VARCHAR(4),
    token_cartao VARCHAR(255),
    ultimos_digitos VARCHAR(4),
    CONSTRAINT fk_cartao_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id)
);

CREATE TABLE IF NOT EXISTS favoritos (
    favoritos_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_usuario_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_favoritos_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(usuario_id),
    CONSTRAINT fk_favoritos_lavanderia FOREIGN KEY (fk_lavanderia_id) REFERENCES lavanderia(lavanderia_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS avaliacao (
    avaliacao_id INT PRIMARY KEY AUTO_INCREMENT,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    comentario VARCHAR(255),
    fk_usuario_id INT,
    fk_lavanderia_id INT,
    CONSTRAINT fk_avaliacao_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(usuario_id),
    CONSTRAINT fk_avaliacao_lavanderia FOREIGN KEY (fk_lavanderia_id) REFERENCES lavanderia(lavanderia_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pedido (
    pedido_id INT PRIMARY KEY AUTO_INCREMENT,
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2),
    taxa_entrega DECIMAL(10,2),
    taxa_entregador DECIMAL(10,2),
    tempo_estimado TIME,
    fk_status_id INT,
    fk_lavanderia_id INT,
    fk_usuario_id INT,
    CONSTRAINT fk_pedido_status FOREIGN KEY (fk_status_id) REFERENCES status(status_id),
    CONSTRAINT fk_pedido_lavanderia FOREIGN KEY (fk_lavanderia_id) REFERENCES lavanderia(lavanderia_id) ON DELETE CASCADE,
    CONSTRAINT fk_pedido_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(usuario_id)
);

-- 5. TABELAS DE DETALHE E PAGAMENTO (NÍVEL 4 - Dependem de Pedido/Cartão)
CREATE TABLE IF NOT EXISTS cesto (
    cesto_id INT PRIMARY KEY AUTO_INCREMENT,
    peso_estimado DECIMAL(5,2),
    secagem ENUM('SIM','NAO') DEFAULT 'NAO',
    tipo_lavagem ENUM('NORMAL','PESADA') DEFAULT 'NORMAL',
    fk_pedido_id INT,
    CONSTRAINT fk_cesto_pedido FOREIGN KEY (fk_pedido_id) REFERENCES pedido(pedido_id)
);

CREATE TABLE IF NOT EXISTS cesto_roupa (
    fk_cesto_id INT,
    fk_roupa_id INT,
    quantidade INT(30),
    PRIMARY KEY (fk_cesto_id, fk_roupa_id),
    CONSTRAINT fk_recebe_cesto FOREIGN KEY (fk_cesto_id) REFERENCES cesto(cesto_id),
    CONSTRAINT fk_recebe_roupa FOREIGN KEY (fk_roupa_id) REFERENCES roupa(roupa_id)
);

CREATE TABLE IF NOT EXISTS ordem_pagamento (
    ordem_pagamento_id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_pagamento ENUM('PIX','CARTAO') NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PAGO','PENDENTE','CANCELADO') DEFAULT 'PENDENTE',
    fk_pedido_id INT,
    CONSTRAINT fk_ordem_pagamento_pedido FOREIGN KEY (fk_pedido_id) REFERENCES pedido(pedido_id)
);

CREATE TABLE IF NOT EXISTS pagamento_cartao (
    pagamento_cartao_id INT PRIMARY KEY AUTO_INCREMENT,
    token_utilizado VARCHAR(255),
    ultimos_digitos VARCHAR(4),
    tipo ENUM('DEBITO','CREDITO'),
    fk_cartao_id INT,
    fk_ordem_pagamento_id INT,
    CONSTRAINT fk_pagamento_cartao_cartao FOREIGN KEY (fk_cartao_id) REFERENCES cartao(cartao_id),
    CONSTRAINT fk_pagamento_cartao_ordem_pagamento FOREIGN KEY (fk_ordem_pagamento_id) REFERENCES ordem_pagamento(ordem_pagamento_id)
);

CREATE TABLE IF NOT EXISTS pix (
    pix_id INT PRIMARY KEY AUTO_INCREMENT,
    chave_pix VARCHAR(255),
    data_expiracao DATETIME,
    qr_code VARCHAR(255),
    status ENUM('PAGO','PENDENTE','EXPIRADO') DEFAULT 'PENDENTE',
    fk_ordem_pagamento_id INT,
    CONSTRAINT fk_pix_ordem_pagamento FOREIGN KEY (fk_ordem_pagamento_id) REFERENCES ordem_pagamento(ordem_pagamento_id)
);

CREATE TABLE cartao_usuario (
    fk_usuario_id INT NOT NULL,
    fk_cartao_id INT NOT NULL,
    
    -- Definindo a Chave Primária Composta (as duas chaves juntas identificam a linha)
    PRIMARY KEY (fk_usuario_id, fk_cartao_id),
    
    -- Definindo as Chaves Estrangeiras
    CONSTRAINT fk_possui_usuario 
        FOREIGN KEY (fk_usuario_id) 
        REFERENCES usuario (usuario_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_possui_cartao 
        FOREIGN KEY (fk_cartao_id) 
        REFERENCES cartao (cartao_id)
        ON DELETE CASCADE
);