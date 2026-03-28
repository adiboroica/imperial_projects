import { useEffect } from 'react';
import { Navigate, Route, Routes } from "react-router-dom";
import '@xyflow/react/dist/style.css';
import AppFooter from './components/layout/AppFooter';
import AppHeader from './components/layout/AppHeader';
import AccountView from './features/account/pages/AccountPage';
import DashboardView from './features/dashboard/pages/DashboardPage';
import GeneratorView from './features/generator/pages/GeneratorPage';
import InitialInputView from './features/initialInput/pages/InitialInputPage';
import LoginView from './features/account/pages/LoginPage';
import SignupView from "./features/account/pages/SignupPage";
import WelcomeView from './features/welcome/pages/WelcomePage';
import { loginWithSession, selectLoggedIn, selectSessionLoginFail } from './store/features/accountSlice';
import { startConnecting } from './store/wsSlice';
import { useAppDispatch, useAppSelector } from './store/hooks';
import {
  ACCOUNT_PAGE,
  DASHBOARD_PAGE,
  GENERATOR_PAGE,
  HOME_PAGE,
  INITIAL_INPUT_PAGE,
  LOGIN_PAGE,
  SIGNUP_PAGE
} from './utils/routes';


const wrapView = (content: JSX.Element) => {
  return (
    <main id="page-container" style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <AppHeader
        links={[
          { label: "Home", link: HOME_PAGE },
          { label: "Dashboard", link: DASHBOARD_PAGE }
        ]}
      />
      <div id="page-body" style={{ flexGrow: 1 }}>
        {content}
      </div>
      <AppFooter />
    </main>
  );
};


function App() {

  const dispatch = useAppDispatch();
  const loggedIn = useAppSelector(selectLoggedIn);
  const sessionLoginFail = useAppSelector(selectSessionLoginFail);


  /****************************************************************
  **** Effects.
  ****************************************************************/

  useEffect(() => {
    dispatch(startConnecting());
  }, [dispatch]);

  useEffect(() => {
    if (!loggedIn) {
      dispatch(loginWithSession());
    }
  }, [dispatch, loggedIn]);


  /****************************************************************
  **** Return.
  ****************************************************************/

  if (loggedIn) {
    return <LoggedInRoutes />;
  }

  if (sessionLoginFail) {
    return <SessionLoginFailedRoutes />;
  }

  return <LoadingRoutes />;

}

export default App;


const HomePage = () => wrapView(<WelcomeView />);

const LoginPage = () => wrapView(<LoginView />);
const SignupPage = () => wrapView(<SignupView />);

const AccountPage = () => wrapView(<AccountView />);
const DashboardPage = () => wrapView(<DashboardView />);
const InitialInputPage = () => wrapView(<InitialInputView />);
const GeneratorPage = () => wrapView(<GeneratorView />);

const LoadingPage = () => wrapView(<></>);


const LoggedInRoutes = () => {
  return (
    <Routes>
      <Route path={HOME_PAGE} element={<HomePage />} />

      <Route path={LOGIN_PAGE} element={<Navigate to={DASHBOARD_PAGE} />} />
      <Route path={SIGNUP_PAGE} element={<Navigate to={DASHBOARD_PAGE} />} />

      <Route path={ACCOUNT_PAGE} element={<AccountPage />} />
      <Route path={DASHBOARD_PAGE} element={<DashboardPage />} />
      <Route path={INITIAL_INPUT_PAGE} element={<InitialInputPage />} />
      <Route path={GENERATOR_PAGE + "*"} element={<GeneratorPage />} />

      <Route path={"*"} element={<Navigate to={HOME_PAGE} />} />
    </Routes>
  );
}

const SessionLoginFailedRoutes = () => {
  return (
    <Routes>
      <Route path={HOME_PAGE} element={<HomePage />} />

      <Route path={LOGIN_PAGE} element={<LoginPage />} />
      <Route path={SIGNUP_PAGE} element={<SignupPage />} />

      <Route path={"*"} element={<Navigate to={LOGIN_PAGE} />} />
    </Routes>
  );
}

const LoadingRoutes = () => {
  return (
    <Routes>
      <Route path={HOME_PAGE} element={<HomePage />} />

      <Route path={"*"} element={<LoadingPage />} />
    </Routes>
  );
}
