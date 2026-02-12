package com.dockerforjavadevelopers.hello.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RootController {

    @GetMapping("/")
    public String index() {
        return "Welcome to Java 21 Spring Boot Sample API. Try /api/hello or /swagger-ui.html";
    }
}
