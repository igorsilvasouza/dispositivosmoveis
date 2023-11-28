const express = require('express');
const disciplinaController = require('../controllers/disciplina_controller');

const router = express.Router();
router.post('/disciplinas/add', disciplinaController.saveDisciplina);
router.get('/disciplinas/list', disciplinaController.listDisciplinas);
router.delete('/disciplinas/:id', disciplinaController.deleteDisciplina);
router.patch('/disciplinas/:id', disciplinaController.updateDisciplina);

module.exports = router;
