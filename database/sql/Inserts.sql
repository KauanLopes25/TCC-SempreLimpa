/* Insert de endereços */
INSERT INTO endereco VALUES (1,'06657300','SP','Itapevi','Rosemary','Rua serra do paracaima','1374',NULL);

/* Insert de usuarios */
INSERT INTO usuario VALUES (1,'Weslei','wees@email.com','11984106174','57030864859',NULL,1,'weslei123');
INSERT INTO usuario VALUES (2,'Maria Silva','maria@email.com','11987654321','12345678901',NULL,1,'maria123');
INSERT INTO usuario VALUES (3,'João Santos','joao@email.com','11991234567','98765432100',NULL,1,'joao123');
INSERT INTO usuario VALUES (4,'Ana Souza','ana@email.com','11999887766','45678912300',NULL,1,'ana123');

/* Insert de lavanderias */
INSERT INTO lavanderia VALUES (2,'5asec',NULL,'04078995000245',NULL,NULL,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnZyjlH6tukWrKpXSTSKNJW5ZFN-ef09tPyA&s','5asec@test.com','11999999998');
INSERT INTO lavanderia VALUES (3,'white Bubble',NULL,'12345678000199',NULL,NULL,'https://via.placeholder.com/150','bubble@test.com','11988888888');
INSERT INTO lavanderia VALUES (4,'Super Clean',NULL,'98765432000188',NULL,NULL,'https://via.placeholder.com/150','superclean@test.com','11977777777');
INSERT INTO lavanderia VALUES (5,'Lavanderia Rápida',NULL,'11222333000155',NULL,NULL,'https://via.placeholder.com/150','rapida@test.com','11966666666');
INSERT INTO lavanderia VALUES (6, 'Premium Clean', 'Especializada em lavagem delicada e roupas finas', '99887766000144', '01:20:00', '00:50:00', 'https://via.placeholder.com/150', 'premiumclean@test.com', '11993334444');

/* Insert de avaliação das lavanderias */
INSERT INTO avaliacao VALUES (3, 5, NOW(), 'Nota 10', 1, 1);
INSERT INTO avaliacao VALUES (4, 4, NOW(), 'Muito boa lavanderia', 1, 3);
INSERT INTO avaliacao VALUES (5, 3, NOW(), 'Serviço ok, pode melhorar', 2, 4);
INSERT INTO avaliacao VALUES (6, 5, NOW(), 'Excelente atendimento!', 3, 5);
INSERT INTO avaliacao VALUES (7, 5, NOW(), 'Ótimo serviço!', 1, 4);
INSERT INTO avaliacao VALUES (8, 4, NOW(), 'Gostei bastante', 2, 5);
INSERT INTO avaliacao VALUES (9, 3, NOW(), 'Serviço razoável', 3, 3);

/* Para mostrar a estrutura da tabela */
desc lavanderia;

/* Para deletar um dado */
delete from avaliacao
where avaliacao_id = 2;

/* Para mostrar a tabela preenchida */
select * from lavanderia;
select * from avaliacao;

/* Para atualizar um insert de dado já feito */
UPDATE lavanderia
SET 
    nome = 'White Bubble',
    cnpj = '12345678000199',
    logo = 'https://via.placeholder.com/150',
    e_mail = 'bubble@test.com',
    telefone = '11966666666'
WHERE lavanderia_id = 3;

/* Insert de status */
INSERT INTO status (status_id, descricao) VALUES
(1, 'PENDENTE'),
(2, 'PAGO'),
(3, 'EM_ANDAMENTO'),
(4, 'FINALIZADO'),
(5, 'CANCELADO');

/* Insert de pedido */
INSERT INTO pedido (
    data, valor_total, taxa_entrega, taxa_entregador,
    tempo_estimado, fk_status_id, fk_lavanderia_id, fk_usuario_id
)
VALUES (
    NOW(), 60, 10, 0, '01:00:00', 1, 2, 1
);

/* Insert de cartão */
INSERT INTO cartao (
    usuario_id, bandeira, validade, token_cartao, ultimos_digitos
)
VALUES (
    1, 'VISA', '1228', 'token_exemplo_abc123', '3456'
);

INSERT INTO pagamento_cartao (
    token_utilizado,
    ultimos_digitos,
    tipo,
    fk_cartao_id,
    fk_ordem_pagamento_id
)
VALUES ('x', '1228', 'CREDITO', 1, 1);

SELECT * FROM pedido;

SELECT * FROM cartao;

SELECT * FROM ordem_pagamento;