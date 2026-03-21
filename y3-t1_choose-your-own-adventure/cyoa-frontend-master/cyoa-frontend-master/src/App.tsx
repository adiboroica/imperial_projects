import 'bootstrap/dist/css/bootstrap.min.css';
import { useEffect } from 'react';
import { Navigate, redirect, Route, Routes, useNavigate } from "react-router-dom";
import 'reactflow/dist/style.css';
import AppFooter from './components/Footer';
import AppHeader from './components/Header';
import AccountView from './pages/account/Account';
import DashboardView from './pages/dashboard/Dashboard';
import GeneratorView from './pages/generator/Generator';
import InitialInputView from './pages/initialInput/InitialInput';
import LoginView from './pages/login/Login';
import SignupView from "./pages/signup/Signup";
import WelcomeView from './pages/welcome/Welcome';
import { loginWithSession, selectLoggedIn, selectSessionLoginFail } from './store/features/accountSlice';
import { startConnecting } from './store/features/wsSlice';
import { useAppDispatch, useAppSelector } from './store/hooks';
import {
  ACCOUNT_PAGE,
  DASHBOARD_PAGE,
  GENERATOR_PAGE,
  HOME_PAGE,
  INITIAL_INPUT_PAGE,
  LOGIN_PAGE,
  SIGNUP_PAGE
} from './utils/pages';


const wrapView = (content: JSX.Element) => {
  return (
    <main id="page-container" className="d-flex flex-column">
      <AppHeader
        links={[
          { label: "Home", link: HOME_PAGE },
          { label: "Dashboard", link: DASHBOARD_PAGE }
        ]}
      />
      <div id="page-body" className="flex-grow-1">
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
