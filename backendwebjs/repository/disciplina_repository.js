const mysql = require('../infra/mysql');

class DisciplinaRepository {
    async addDisciplina(disciplina) {
        const con = await mysql.getConnection();
        const sqlInsert = 'INSERT INTO disciplina (nome, cargaHoraria, dificuldade, recursos, prazo, metas, prioridade) VALUES (?, ?, ?, ?, ?, ?, ?)';
        const params = [disciplina.nome, disciplina.cargaHoraria, disciplina.dificuldade, disciplina.recursos, disciplina.prazo,disciplina.metas, disciplina.prioridade];
        return await con.execute(sqlInsert, params);
    }

    async listDisciplinas() {
        const con = await mysql.getConnection();
        console.log('Requesting disciplinas from db');
        const sqlSelect = 'SELECT * FROM ppmi2023.disciplina';
        return await con.query(sqlSelect);
    }

    async updateDisciplina(id, disciplina) {
        const con = await mysql.getConnection();
        const sqlUpdate = 'UPDATE disciplina SET nome=?, cargaHoraria=?, dificuldade=?, recursos=?, prazo=?, prioridade=? WHERE id=?';
        const params = [disciplina.nome, disciplina.cargaHoraria, disciplina.dificuldade, disciplina.recursos, disciplina.prazo, disciplina.prioridade, id];
        return await con.execute(sqlUpdate, params);
    }

    async deleteDisciplina(id) {
        const con = await mysql.getConnection();
        const sqlDelete = 'DELETE FROM disciplina WHERE id=?';
        return await con.execute(sqlDelete, [id]);
    }
}

module.exports = new DisciplinaRepository();
