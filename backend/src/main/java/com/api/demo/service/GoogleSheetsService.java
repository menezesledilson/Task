package com.api.demo.service;
import com.api.demo.model.TarefaDTO;
import com.google.api.services.sheets.v4.Sheets;
import com.google.api.services.sheets.v4.model.ValueRange;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.jackson2.JacksonFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
 @Service
 public class GoogleSheetsService {

        private final Sheets sheetsService;
        private static final String SPREADSHEET_ID = "1yaEs2P6H4Qik0wiEjF-M_v5EAnbrG7qe6wjsiuRBcfQ"; // <- coloque aqui
        private static final String RANGE = "A:C";

     public GoogleSheetsService() throws IOException, GeneralSecurityException {
         String jsonCredenciais = System.getenv("GOOGLE_CREDENTIALS_JSON");
         if (jsonCredenciais == null || jsonCredenciais.isEmpty()) {
             throw new IllegalStateException("Variável GOOGLE_CREDENTIALS_JSON não está definida");
         }
         GoogleCredentials credentials = GoogleCredentials.fromStream(
                 new ByteArrayInputStream(jsonCredenciais.getBytes(StandardCharsets.UTF_8))
         ).createScoped(List.of("https://www.googleapis.com/auth/spreadsheets"));

         this.sheetsService = new Sheets.Builder(
                 GoogleNetHttpTransport.newTrustedTransport(),
                 JacksonFactory.getDefaultInstance(),
                 new HttpCredentialsAdapter(credentials)
         ).setApplicationName("AppTarefas").build();
     }

     public void adicionarTarefa(String descricao) throws IOException {
            String dataAtual = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            String HoraAtual = LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm"));

            List<List<Object>> valores = List.of(List.of(dataAtual,HoraAtual, descricao));

            ValueRange corpo = new ValueRange().setValues(valores);

            sheetsService.spreadsheets().values()
                    .append(SPREADSHEET_ID, RANGE, corpo)
                    .setValueInputOption("USER_ENTERED")
                    .execute();
        }

     public List<TarefaDTO> listarTarefas() throws IOException {
         List<TarefaDTO> tarefas = new ArrayList<>();

         ValueRange response = sheetsService.spreadsheets().values()
                 .get(SPREADSHEET_ID, RANGE)
                 .execute();

         List<List<Object>> valores = response.getValues();

         if (valores == null || valores.isEmpty()) {
             return tarefas;
         }

         for (List<Object> linha : valores) {
             if (linha.size() >= 3) {
                 String data = linha.get(0).toString();      // coluna A
                 String hora = linha.get(1).toString();      // coluna B
                 String descricao = linha.get(2).toString(); // coluna C

                 TarefaDTO tarefa = new TarefaDTO();
                 tarefa.setData(data);
                 tarefa.setHora(hora);
                 tarefa.setDescricao(descricao);
                 tarefas.add(tarefa);
             }
         }

         return tarefas;
     }

 }
