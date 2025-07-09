package com.api.demo.controller;

import com.api.demo.model.TarefaDTO;
import com.api.demo.service.GoogleSheetsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tarefas")
public class TarefaController {

    private final GoogleSheetsService googleSheetsService;

    public TarefaController(GoogleSheetsService googleSheetsService) {
        this.googleSheetsService = googleSheetsService;
    }
    @PostMapping
    public ResponseEntity<String> adicionarTarefa(@RequestBody TarefaDTO tarefaDTO) {
        try {
            googleSheetsService.adicionarTarefa(tarefaDTO.getDescricao());
            return ResponseEntity.ok("Tarefa enviada com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Erro ao enviar tarefa: " + e.getMessage());
        }
    }
    @GetMapping
    public ResponseEntity<List<TarefaDTO>> listarTarefas() {
        try {
            List<TarefaDTO> tarefas = googleSheetsService.listarTarefas();
            return ResponseEntity.ok(tarefas);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }

}
