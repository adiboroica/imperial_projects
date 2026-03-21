import { Button, createStyles, Group, PasswordInput, Stack, Text, TextInput, Title } from "@mantine/core";
import { FormEvent, useState } from "react";
import { Link } from "react-router-dom";
import { selectSignupError, signup } from "../../store/features/accountSlice";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { LOGIN_PAGE } from "../../utils/pages";

const useStyles = createStyles((theme, _params) => ({
	
	box: {
		width: "100vw",
		height: "92vh",
		alignItems: "center",
	},

	stack: {
		backgroundColor: theme.white,
		height: 380,
		width: 320,
		borderRadius: 6,
		boxShadow: theme.shadows.md,
		padding: 20,
		margin: "auto",
		alignItems: "center"
	}
}))

const SignupView = () => {
	const { classes } = useStyles();

	const dispatch = useAppDispatch();
	const signupError = useAppSelector(selectSignupError);

	const [email, setEmail] = useState("");
	const [password, setPassword] = useState("");


	const onSignupSubmit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault();
		dispatch(signup({ email, password }));
	};


	return (
		<Group
			className={classes.box}>
			<Stack className={classes.stack}>
				<Title order={2} c="black">Sign Up</Title>
				<form onSubmit={onSignupSubmit}>
					<TextInput
						label="Email"
						variant="filled"
						placeholder="your@email.com"
						value={email}
						onChange={(event: React.ChangeEvent<HTMLInputElement>) => setEmail(event.target.value)}
						mb="lg"
					/>

					<PasswordInput
						placeholder="Password"
						label="Password"
						variant="filled"
						value={password}
						onChange={(event: React.ChangeEvent<HTMLInputElement>) => setPassword(event.target.value)}
					/>
					{signupError &&
						<Text fz="xs" c="red">Invalid credentials.</Text>
					}


					<Stack mt="md">
						<Button
							type="submit"
							variant="gradient"
							gradient={{ from: 'cyan', to: 'indigo' }}>
							Sign Up
						</Button>
						<Group position="center">
							<Link to={LOGIN_PAGE}>
								<Text fz="sm" c="blue" td="underline">
									Already a user? Log In.
								</Text>
							</Link>
						</Group>
					</Stack>
				</form>
			</Stack>
		</Group>
	);
};

export default SignupView;
