/*******************************************************************************************
 * Objetivo: Arquivo responsável pelos padrões de mensagens que o projeto irá realizar, sempre no formato JSON (mensagens de erro e sucesso, etc)
 * Data: 17/04/2026
 * Autor: Arthur Angelues
 * Versão: 1.0
 *******************************************************************************************/

//Cria um objeto da classe Date para pegar a data atual
const data_atual = new Date();

/**************************************MENSAGENS PADRONIZADAS*******************************/
const DEFAULT_HEADER = {development: 'Arthur Angelus', 
                        api_description: 'API para delivery de roupas a lavanderia',
                        status: Boolean,
                        status_code: Number,
                        request_date: data_atual.toLocaleString(), //toString
                        items: {}
                        }

/**************************************MENSAGENS DE SUCESSO*********************************/
const SUCCESS_REQUEST                    = {status: true, status_code: 200, message: 'Requisição bem sucedida!!!'}

const SUCCESS_CREATED_ITEM              = {status: true, status_code: 201, message: 'Ação realizada com sucesso!!!'}

const SUCCESS_UPDATED_ITEM              = {status: true, status_code: 200, message: 'Ação realizada com sucesso!!!'}

const SUCCESS_DELETED_ITEM              = {status: true, status_code: 200, message: 'Ação realizada com sucesso!!!'}



/**************************************MENSAGENS DE ERRO***********************************/
const ERROR_NOT_FOUND                    ={status: false, status_code: 404, message: 'Não foram encontrados dados de retorno!!!'}

const ERROR_INTERNAL_SERVER_CONTROLLER   ={status: false, status_code: 500, message: 'Não foi possível processar a requisição devido a erros internos no servidor(CONTROLLER)!!!'}

const ERROR_INTERNAL_SERVER_MODEL        ={status: false, status_code: 500, message: 'Não foi possível processar a requisição devido a erros internos no servidor(MODEL)!!!'}

const ERROR_REQUIRED_FIELDS              ={status: false, status_code: 400, message: 'Não foi possível processar a requisição, pois existem campos obrigatórios que devem ser encaminhados e atendidos conforme a documentação'}

const ERROR_CONTENT_TYPE                 ={status: false, status_code: 415, message: 'Não foi possível processar a requisição, pois o tipo de dados enviado no corpo deve ser JSON'}

const ERROR_RELATION_INSERT              ={status: false, status_code: 500,message: 'A inserção do item principal foi processada com sucesso, porém houveram problemas ao inserir dados na tabela de relação'}

module.exports = {
    DEFAULT_HEADER,
    SUCCESS_REQUEST,
    SUCCESS_CREATED_ITEM,
    SUCCESS_UPDATED_ITEM,
    SUCCESS_DELETED_ITEM,
    ERROR_NOT_FOUND,
    ERROR_INTERNAL_SERVER_CONTROLLER,
    ERROR_INTERNAL_SERVER_MODEL,
    ERROR_REQUIRED_FIELDS,
    ERROR_CONTENT_TYPE,
    ERROR_RELATION_INSERT
}