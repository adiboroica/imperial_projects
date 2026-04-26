/**
 * App composition — top-level router, auth boot, WS lifecycle.
 *
 * Reads `state.auth.{loggedIn, bootstrapping}` via typed hooks and dispatches
 * `session()` once at mount to restore the user. After login, opens the WS
 * connection. Wires `AppHeader` and `AppMenu` (both presentational) with the
 * data and callbacks they need.
 */

import { useEffect, useMemo } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import "@xyflow/react/dist/style.css";

import { generation } from "./api";
import AppFooter from "./components/layout/AppFooter";
import AppHeader from "./components/layout/AppHeader";
import {
  logout,
  selectAuthBootstrapping,
  selectAuthLoggedIn,
  session,
} from "./features/auth/slices/auth";
import AccountPage from "./pages/account/AccountPage";
import DashboardPage from "./pages/dashboard/DashboardPage";
import GeneratorPage from "./pages/generator/GeneratorPage";
import LoginPage from "./pages/login/LoginPage";
import SetupPage from "./pages/setup/SetupPage";
import SignupPage from "./pages/signup/SignupPage";
import WelcomePage from "./pages/welcome/WelcomePage";
import { useAppDispatch, useAppSelector } from "./store/hooks";
import {
  ACCOUNT_PAGE,
  DASHBOARD_PAGE,
  GENERATOR_PAGE,
  HOME_PAGE,
  LOGIN_PAGE,
  SETUP_PAGE,
  SIGNUP_PAGE,
} from "./utils/routes";

type WrapProps = {
  loggedIn: boolean;
  onLogout: () => void;
  children: JSX.Element;
};

const Wrap = ({ loggedIn, onLogout, children }: WrapProps) => (
  <main
    id="page-container"
    style={{ display: "flex", flexDirection: "column", minHeight: "100vh" }}
  >
    <AppHeader
      loggedIn={loggedIn}
      onLogout={onLogout}
      links={loggedIn ? [{ label: "Dashboard", link: DASHBOARD_PAGE }] : []}
    />
    <div id="page-body" style={{ flexGrow: 1 }}>
      {children}
    </div>
    <AppFooter />
  </main>
);

const App = () => {
  const dispatch = useAppDispatch();
  const loggedIn = useAppSelector(selectAuthLoggedIn);
  const bootstrapping = useAppSelector(selectAuthBootstrapping);

  // Restore session once at boot.
  useEffect(() => {
    dispatch(session());
  }, [dispatch]);

  // Open the WS connection after login.
  useEffect(() => {
    if (!loggedIn) return;
    void generation.connect().catch(() => {
      // Re-tries handled per-call; failures surface via notifications.
    });
  }, [loggedIn]);

  const onLogout = useMemo(
    () => () => {
      void dispatch(logout());
      generation.close();
    },
    [dispatch],
  );

  const wrap = (page: JSX.Element) => (
    <Wrap loggedIn={loggedIn} onLogout={onLogout}>
      {page}
    </Wrap>
  );

  if (bootstrapping) {
    return wrap(<div />);
  }

  if (loggedIn) {
    return (
      <Routes>
        <Route path={HOME_PAGE} element={<Navigate to={DASHBOARD_PAGE} />} />
        <Route path={DASHBOARD_PAGE} element={wrap(<DashboardPage />)} />
        <Route path={ACCOUNT_PAGE} element={wrap(<AccountPage />)} />
        <Route path={SETUP_PAGE} element={wrap(<SetupPage />)} />
        <Route
          path={`${GENERATOR_PAGE}:storyId`}
          element={wrap(<GeneratorPage />)}
        />
        <Route path={LOGIN_PAGE} element={<Navigate to={DASHBOARD_PAGE} />} />
        <Route path={SIGNUP_PAGE} element={<Navigate to={DASHBOARD_PAGE} />} />
        <Route path="*" element={<Navigate to={DASHBOARD_PAGE} />} />
      </Routes>
    );
  }

  return (
    <Routes>
      <Route path={HOME_PAGE} element={wrap(<WelcomePage />)} />
      <Route path={LOGIN_PAGE} element={wrap(<LoginPage />)} />
      <Route path={SIGNUP_PAGE} element={wrap(<SignupPage />)} />
      <Route path="*" element={<Navigate to={HOME_PAGE} />} />
    </Routes>
  );
};

export default App;
