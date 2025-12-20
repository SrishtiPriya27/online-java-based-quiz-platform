package com.example.quizplatform.web.filter;

import com.example.quizplatform.model.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
        // No initialization required
    }

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();

        /* ---------- Allow public resources ---------- */
        if (uri.endsWith("login.jsp") ||
            uri.endsWith("LoginServlet") ||
            uri.endsWith("LogoutServlet") ||
            uri.contains("/css/") ||
            uri.contains("/js/") ||
            uri.contains("/images/")) {

            chain.doFilter(request, response);
            return;
        }

        /* ---------- Authentication check ---------- */
        User user = (session != null)
                ? (User) session.getAttribute("user")
                : null;

        if (user == null) {
            res.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        /* ---------- Role-based authorization ---------- */
        String role = user.getRole().toLowerCase();

        if (uri.startsWith(contextPath + "/admin/")
                && !role.equals("admin")) {
            res.sendRedirect(contextPath + "/login.jsp?error=unauthorized");
            return;
        }

        if (uri.startsWith(contextPath + "/creator/")
                && !(role.equals("creator") || role.equals("admin"))) {
            res.sendRedirect(contextPath + "/login.jsp?error=unauthorized");
            return;
        }

        if (uri.startsWith(contextPath + "/participant/")
                && !(role.equals("participant") || role.equals("admin"))) {
            res.sendRedirect(contextPath + "/login.jsp?error=unauthorized");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup required
    }
}
