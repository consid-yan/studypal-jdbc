# StudyPal JDBC

## Local AI config

AI sub-task generation is configured locally. The real API key should not be committed.

1. Copy the template:

   ```bash
   cp src/main/resources/studypal-local.properties.example src/main/resources/studypal-local.properties
   ```

2. Fill in these values in `src/main/resources/studypal-local.properties`:

   ```properties
   studypal.ai.apiUrl=https://your-ai-provider-base-url
   studypal.ai.apiKey=your-api-key
   studypal.ai.model=your-model-name
   ```

3. Restart the application.

The application also supports JVM properties and environment variables. Precedence is:

1. JVM properties, such as `-Dstudypal.ai.apiKey=...`
2. Environment variables, such as `STUDYPAL_AI_API_KEY`
3. `src/main/resources/studypal-local.properties`
4. Built-in defaults

When AI config is missing or the API call fails, StudyPal still creates the task and falls back to one default sub-task.
