use sempre_limpa_db;

CREATE TABLE endereco (
    endereco_PK INT PRIMARY KEY,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE endereco_lavanderia (
	endereco_lavanderia_PK INT PRIMARY KEY,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro varchar(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
    );

CREATE TABLE usuario (
    usuario_id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    e_mail VARCHAR(100) NOT NULL,
    telefone VARCHAR(11) NOT NULL,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    rne VARCHAR(9),
    senha varchar(12) NOT NULL,
    fk_endereco INT NOT NULL,
    CONSTRAINT fk_usuario_endereco
        FOREIGN KEY (fk_endereco)
        REFERENCES endereco(endereco_PK)
        ON DELETE CASCADE
);

CREATE TABLE status (
    status_id INT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE lavanderia (
    lavanderia_id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(300),
    cnpj VARCHAR(14) NOT NULL UNIQUE,
    tempo_padrao_lavagem TIME,
    tempo_secagem TIME,
    logo VARCHAR(255) NOT NULL,
    e_mail VARCHAR(255) NOT NULL,
    telefone VARCHAR(11) NOT NULL
);

ALTER TABLE pedido 
MODIFY pedido_id INT NOT NULL AUTO_INCREMENT;

ALTER TABLE cesto 
DROP FOREIGN KEY fk_cesto_pedido;

CREATE TABLE pedido (
    pedido_id INT PRIMARY KEY,
    data DATETIME NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    taxa_entrega DECIMAL(10,2) NOT NULL,
    taxa_entregador DECIMAL(10,2) NOT NULL,
    tempo_estimado TIME NOT NULL,
    fk_status_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_pedido_status
        FOREIGN KEY (fk_status_id)
        REFERENCES status(status_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pedido_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
        ON DELETE CASCADE
);

ALTER TABLE pedido 
ADD COLUMN fk_usuario_id INT NOT NULL;

ALTER TABLE pedido
ADD CONSTRAINT fk_pedido_usuario
FOREIGN KEY (fk_usuario_id)
REFERENCES usuario(usuario_id)
ON DELETE CASCADE;

CREATE TABLE cesto (
    cesto_id INT PRIMARY KEY,
    peso_estimado DECIMAL(5,2) NOT NULL,
    secagem ENUM('SIM', 'NAO') NOT NULL,
    tipo_lavagem ENUM('NORMAL', 'PESADA') NOT NULL,
    fk_pedido_id INT NOT NULL,
    CONSTRAINT fk_cesto_pedido
        FOREIGN KEY (fk_pedido_id)
        REFERENCES pedido(pedido_id)
        ON DELETE CASCADE
);

CREATE TABLE ordem_pagamento (
    ordem_pagamento_id INT PRIMARY KEY,
    tipo_pagamento ENUM('PIX', 'CARTAO'),
    valor DECIMAL(10,2) NOT NULL,
    data_criacao DATETIME NOT NULL,
    status ENUM('PAGO', 'PENDENTE', 'CANCELADO') NOT NULL,
    fk_pedido_id INT NOT NULL,
    CONSTRAINT fk_ordem_pedido
        FOREIGN KEY (fk_pedido_id)
        REFERENCES pedido(pedido_id)
        ON DELETE CASCADE
);

CREATE TABLE cartao (
    cartao_id INT PRIMARY KEY,
    usuario_id INT NOT NULL,
    bandeira VARCHAR(20) NOT NULL,
    validade VARCHAR(4) NOT NULL,
    token_cartao VARCHAR(255) NOT NULL,
    ultimos_digitos VARCHAR(4) NOT NULL,
    CONSTRAINT fk_cartao_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(usuario_id)
        ON DELETE CASCADE
);

CREATE TABLE pagamento_cartao (
    pagamento_cartao_id INT PRIMARY KEY,
    token_utilizado VARCHAR(255) NOT NULL,
    ultimos_digitos VARCHAR(4) NOT NULL,
    tipo ENUM('DEBITO', 'CREDITO') NOT NULL,
    fk_cartao_id INT NOT NULL,
    fk_ordem_pagamento_id INT NOT NULL,
    CONSTRAINT fk_pagamento_cartao_cartao
        FOREIGN KEY (fk_cartao_id)
        REFERENCES cartao(cartao_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pagamento_cartao_ordem
        FOREIGN KEY (fk_ordem_pagamento_id)
        REFERENCES ordem_pagamento(ordem_pagamento_id)
        ON DELETE CASCADE
);

CREATE TABLE pix (
    pix_id INT PRIMARY KEY,
    chave_pix VARCHAR(255) NOT NULL,
    data_expiracao DATETIME NOT NULL,
    qr_code VARCHAR(255) NOT NULL,
    status ENUM('PAGO', 'PENDENTE', 'EXPIRADO') NOT NULL,
    fk_ordem_pagamento_id INT NOT NULL,
    CONSTRAINT fk_pix_ordem
        FOREIGN KEY (fk_ordem_pagamento_id)
        REFERENCES ordem_pagamento(ordem_pagamento_id)
        ON DELETE CASCADE
);

CREATE TABLE avaliacao (
    avaliacao_id INT PRIMARY KEY,
    nota INT NOT NULL,
    data DATETIME NOT NULL,
    comentario VARCHAR(255) NOT NULL,
    fk_usuario_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_avaliacao_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_avaliacao_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
        ON DELETE CASCADE
);

CREATE TABLE roupas (
    id INT PRIMARY KEY,
    quantidade INT NOT NULL,
    nome_peca VARCHAR(100) NOT NULL
);

CREATE TABLE recebe (
    fk_cesto_id INT NOT NULL,
    fk_roupas_id INT NOT NULL,
    PRIMARY KEY (fk_cesto_id, fk_roupas_id),
    CONSTRAINT fk_recebe_cesto
        FOREIGN KEY (fk_cesto_id)
        REFERENCES cesto(cesto_id),
    CONSTRAINT fk_recebe_roupas
        FOREIGN KEY (fk_roupas_id)
        REFERENCES roupas(id)
);

CREATE TABLE favoritos (
    favoritos_id INT PRIMARY KEY,
    fk_usuario_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_favoritos_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id),
    CONSTRAINT fk_favoritos_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
);