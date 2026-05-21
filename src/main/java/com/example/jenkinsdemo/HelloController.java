package com.example.jenkinsdemo;

import java.time.Instant;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/hello")
    public Map<String, String> hello() {
        return Map.of(
                // "message", "Hello from Jenkins Docker Desktop demo",
                "message", "Hello from Jenkins auto build",
                "timestamp", Instant.now().toString()
        );
    }
}
