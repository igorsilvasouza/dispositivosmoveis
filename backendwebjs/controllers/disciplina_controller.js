const disciplinaRepository = require('../repository/disciplina_repository');
const colors = require('colors');
var cors = require('cors');

const saveDisciplina = async (req, res) => {
    const disciplina = {
        'nome': req.body.nome,
        'cargaHoraria': req.body.cargaHoraria,
        'dificuldade': req.body.dificuldade,
        'recursos': req.body.recursos,
        'prazo': req.body.prazo,
        'metas': req.body.metas.join(','),
        'prioridade': req.body.prioridade
    };

    if(validarCampos(disciplina)) return res.status(400).send(`Campo inválido: ${validacao}`);;

    console.log(colors.bgGreen(disciplina));
    const result = await disciplinaRepository.addDisciplina(disciplina);
    res.status(200).send(disciplina);
};

const listDisciplinas = async (req, res) => {
    const disciplinas = await disciplinaRepository.listDisciplinas();
    let disciplinasDTO = [];

    disciplinas[0].forEach(disciplina => {
        const disciplinaDTO = {
            id: disciplina.id,
            nome: disciplina.nome,
            cargaHoraria: disciplina.cargaHoraria,
            dificuldade: disciplina.dificuldade,
            recursos: disciplina.recursos,
            prazo: disciplina.prazo,
            metas: disciplina.metas,
            prioridade: disciplina.prioridade
        };

        disciplinasDTO.push(disciplinaDTO);
    });

    console.log('Disciplinas DTO ' + JSON.stringify(disciplinasDTO));
    res.status(201).send(disciplinasDTO);
};


function validarCampos(body) {
    if (!body.nome || typeof body.nome !== 'string') {
        return 'O campo "nome" é obrigatório e deve ser uma string.';
    }

    if (!body.cargaHoraria || typeof body.cargaHoraria !== 'number') {
        return 'O campo "cargaHoraria" é obrigatório e deve ser um número.';
    }

    if (!body.dificuldade || (body.dificuldade !== 'baixa' && body.dificuldade !== 'média' && body.dificuldade !== 'alta')) {
        return 'O campo "dificuldade" é obrigatório e deve ser "baixa", "média" ou "alta".';
    }

    if (!body.recursos || typeof body.recursos !== 'string') {
        return 'O campo "recursos" é obrigatório e deve ser uma string.';
    }

    if (!body.prazo || typeof body.prazo !== 'string') {
        return 'O campo "prazo" é obrigatório e deve ser uma string.';
    }

    if (!body.metas) {
        return 'O campo "metas" é obrigatório e deve ser uma lista de metas.';
    }

    if (!body.prioridade || (body.prioridade !== 'baixa' && body.prioridade !== 'média' && body.prioridade !== 'alta')) {
        return 'O campo "prioridade" é obrigatório e deve ser "baixa", "média" ou "alta".';
    }

    return false;
}

const deleteDisciplina = async (req, res) => {
    const disciplinaId = req.params.id;

    if (!disciplinaId || isNaN(disciplinaId)) {
        return res.status(400).send('ID inválido.');
    }

    const result = await disciplinaRepository.deleteDisciplina(disciplinaId);

    if (result.affectedRows === 0) {
        return res.status(404).send('Disciplina não encontrada.');
    }

    res.status(200).send('Disciplina excluída com sucesso.');
};

const updateDisciplina = async (req, res) => {
    const disciplinaId = req.params.id;

    if (!disciplinaId || isNaN(disciplinaId)) {
        return res.status(400).send('ID inválido.');
    }

    const disciplina = {
        'nome': req.body.nome,
        'cargaHoraria': req.body.cargaHoraria,
        'dificuldade': req.body.dificuldade,
        'recursos': req.body.recursos,
        'prazo': req.body.prazo,
        'metas': req.body.metas,
        'prioridade': req.body.prioridade
    };

    const validacao = validarCampos(disciplina);

    if (validacao) {
        return res.status(400).send(`Campo inválido: ${validacao}`);
    }

    const result = await disciplinaRepository.updateDisciplina(disciplinaId, disciplina);

    if (result.affectedRows === 0) {
        return res.status(404).send('Disciplina não encontrada.');
    }

    res.status(200).send('Disciplina atualizada com sucesso.');
};

module.exports = { saveDisciplina, listDisciplinas, deleteDisciplina, updateDisciplina };